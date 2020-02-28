using Amazon.Lambda.Core;
using Amazon.Lambda.RuntimeSupport;
using Amazon.Lambda.Serialization.Json;
using Amazon.S3;
using Amazon.S3.Model;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.IO;
using System.Data;
using MySql.Data.MySqlClient;
using System.Linq.Expressions;
using System.Linq;
using System.Text.RegularExpressions;
using Amazon.SecretsManager;
using Amazon.SecretsManager.Model;

namespace SqlToS3Exporter
{
    public class Function
    {

        IAmazonS3 S3Client { get; set; }

        /// <summary>
        /// Default constructor. This constructor is used by Lambda to construct the instance. When invoked in a Lambda environment
        /// the AWS credentials will come from the IAM role associated with the function and the AWS region will be set to the
        /// region the Lambda function is executed in.
        /// </summary>
        public Function()
        {
            S3Client = new AmazonS3Client();
        }

        /// <summary>
        /// Constructs an instance with a preconfigured S3 client. This can be used for testing the outside of the Lambda environment.
        /// </summary>
        /// <param name="s3Client"></param>
        public Function(IAmazonS3 s3Client)
        {
            this.S3Client = s3Client;
        }

        private static async Task Main(string[] args)
        {
            Func<dynamic, ILambdaContext ,string> func = FunctionHandler;
            using(var handlerWrapper = HandlerWrapper.GetHandlerWrapper(func, new JsonSerializer()))
            using(var bootstrap = new LambdaBootstrap(handlerWrapper))
            {
                await bootstrap.RunAsync();
            }
        }

        /// <summary>
        /// A simple function that takes a string and does a ToUpper
        ///
        /// To use this handler to respond to an AWS event, reference the appropriate package from 
        /// https://github.com/aws/aws-lambda-dotnet#events
        /// and change the string input parameter to the desired event type.
        /// </summary>
        /// <param name="input"></param>
        /// <param name="context"></param>
        /// <returns></returns>
        public static string FunctionHandler(dynamic input, ILambdaContext context)
        {

            bool bStatus = true;
            int queriesCompleted = 0;
            var envVariables = System.Environment.GetEnvironmentVariables();
            string OutBucket = envVariables.Contains("OutBucket") ? envVariables["OutBucket"].ToString() : string.Empty;
            string PrefixKey = envVariables.Contains("PrefixKey") ? envVariables["PrefixKey"].ToString() : string.Empty;
            string QueryPrefixKey = envVariables.Contains("QueryPrefixKey") ? envVariables["QueryPrefixKey"].ToString() : string.Empty;
            string QuerySourceBucket = envVariables.Contains("QuerySourceBucket") ? envVariables["QuerySourceBucket"].ToString() : string.Empty;
            string AWS_DEFAULT_REGION = envVariables.Contains("AWS_DEFAULT_REGION") ? envVariables["AWS_DEFAULT_REGION"].ToString() : string.Empty;
            string AccountNumber = envVariables.Contains("AccountNumber") ? envVariables["AccountNumber"].ToString() : string.Empty;


            string Server = envVariables.Contains("Server") ? envVariables["Server"].ToString() : string.Empty;
            string User = envVariables.Contains("User") ? envVariables["User"].ToString() : "master";
            string Database = envVariables.Contains("Database") ? envVariables["Database"].ToString() : string.Empty;
            string ServerPort = envVariables.Contains("ServerPort") ? envVariables["ServerPort"].ToString() : "3306";

            string UserPassword = envVariables.Contains("UserPassword") ? envVariables["UserPassword"].ToString() : string.Empty; ;




            string CsvDelimiter = envVariables.Contains("CsvDelimiter") ? envVariables["CsvDelimiter"].ToString() : ",";

            var queryfiles = from keyNames in GetQueriesKeysFromBucket(QuerySourceBucket, QueryPrefixKey) where keyNames.EndsWith(".sql") select keyNames;
            Dictionary<string, string> queries = GetQueriesFromBucket(QuerySourceBucket, queryfiles.ToList());
            int totalNoQueries = queries.Count;
            string datetime = DateTime.UtcNow.ToString("yyyyMMddhhmmss");
            string failedQueries = "";

            //foreach (KeyValuePair<string, string> query in queries)
            //{
            //    try
            //    {
            //        UploadToS3(context, OutBucket, String.Format("{0}", query.Key), query.Value.ToStream(), false);
            //    }
            //    catch (Exception ex)
            //    {
            //        context.Logger.LogLine(string.Format("An error occured writing the query {0}, to bucket {1}"
            //                , query.Key, QuerySourceBucket));
            //        context.Logger.LogLine(ex.ToString());
            //    }
            //}


            foreach (KeyValuePair<string, string> query in queries)
            {
                string queryName = query.Key.Split("/").Last();
                DataTable tempTable = new DataTable();
                tempTable.Reset();

                string connStr = string.Format("server=" +
                    "{0};" +
                    "user={1};database={2};" +
                    "port={3};password=<<Password>>", Server, User, Database, ServerPort);
                using (MySqlConnection conn = new MySqlConnection(connStr))
                {
                    try
                    {
                        string fileName = Regex.Replace(queryName, "\\.sql$", ".csv");
                        
                        conn.Open();
                        MySqlCommand cmd = new MySqlCommand(query.Value, conn);
                        MySqlDataReader rdr = cmd.ExecuteReader();
                        tempTable.Load(rdr);

                        UploadToS3(context
                            , OutBucket
                            , string.Format("{0}/{1}/{2}", PrefixKey, datetime, fileName)
                            , tempTable.ToCSV("|").ToStream()
                            );

                        queriesCompleted++;
                    }
                    catch (Exception ex)
                    {
                        context.Logger.LogLine(string.Format("An error occured executing the query {0}"
                            , query.Key));
                        Console.WriteLine(ex.ToString());
                        bStatus = false;
                        failedQueries = string.Join(",", failedQueries, queryName);
                    }
                }
            }

            if(!bStatus)
            {
                return string.Format("{0} : {1}/{2} queries completed \n The following queries failed: {3}", bStatus.ToString(), queriesCompleted, totalNoQueries, failedQueries);
            }
            return string.Format("{0} : {1}/{2} queries completed", bStatus.ToString(), queriesCompleted, totalNoQueries);

        }

        public static bool UploadToS3(ILambdaContext context, string bucketName
            , string key
            , Stream stream)
        {
            string keyName = key;

            try
            {
                var putRequest = new PutObjectRequest
                {
                    BucketName = bucketName,
                    Key = keyName,
                    ContentType = "text/csv"
                };
                putRequest.InputStream = stream;
                var S3Client = new AmazonS3Client(Amazon.RegionEndpoint.EUWest1);
                var putObjectResponse = S3Client.PutObjectAsync(putRequest).Result;
            }
            catch (Exception ex)
            {
                context.Logger.LogLine(ex.Message);
                context.Logger.LogLine(String.Format("Unable to write to file {0}, to bucket {1}."
                    , keyName , bucketName));
                context.Logger.LogLine(ex.ToString());
                return false;
            }
            return true;
        }

        public static List<string> GetQueriesKeysFromBucket(string bucket, string keyPrefix)
        {
            List<string> queriesKeys = new List<string>();
            AmazonS3Client client = new AmazonS3Client(Amazon.RegionEndpoint.EUWest1);
            ListObjectsRequest listRequest = new ListObjectsRequest
            {
                BucketName = bucket,
                Prefix = keyPrefix
            };

            ListObjectsResponse listResponse;
            do
            {
                listResponse = client.ListObjectsAsync(listRequest).Result;
                foreach (S3Object obj in listResponse.S3Objects)
                {
                    queriesKeys.Add(obj.Key);
                }

                listRequest.Marker = listResponse.NextMarker;
            } while (listResponse.IsTruncated);
            return queriesKeys;
        }

        public static Dictionary<string, string> GetQueriesFromBucket(string bucket
            , List<string> keys)
        {
            var S3Client = new AmazonS3Client(Amazon.RegionEndpoint.EUWest1);
            Dictionary<string, string> files = new Dictionary<string, string>();
            foreach (string key in keys) 
            {
                GetObjectRequest request = new GetObjectRequest
                {
                    BucketName = bucket,
                    Key = key
                };
                using (StreamReader streamReader = new StreamReader(
                    S3Client.GetObjectAsync(request).Result.ResponseStream))
                {
                    files.Add(key, streamReader.ReadToEnd());
                }
            }
            return files;
        }
         

        private static string GetPassword(string SecretId)
        {
            var secretManagerClient = new AmazonSecretsManagerClient(Amazon.RegionEndpoint.EUWest1);
            GetSecretValueRequest request = new GetSecretValueRequest();
            request.SecretId = SecretId;
            var response = secretManagerClient.GetSecretValueAsync(request).Result;
            return response.SecretString;
        }
    }
}
