using Amazon.Lambda.Core;
using Amazon.Lambda.RuntimeSupport;
using Amazon.Lambda.Serialization.Json;
using Amazon.S3;
using Amazon.S3.Model;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.IO;
using System.Data;
using MySql.Data.MySqlClient;


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
            string qryTravelLocation = @"
            SELECT tid `location_id`, geo_level,`en-gb` `location_name`	
                FROM cms.ten_cache_location;
            ";
            string qryHotels = @"
            SELECT DISTINCT
                 n.nid `accommodation_id`
			    ,nfpr.field_propertyreferenceid_value `ivector_id`
			    ,nfd.title `accommodation_name`
			    ,IFNULL(ttfd.name, '') `rating`
			    ,cplv.property_latitude `latitude`
			    ,cplv.property_longitude `longitude`
			    ,cplv.location_tid `location_id`
			    ,IFNULL(nfbi.field_benefit_included_value, 0) `is_benefits_hotel`
		    FROM cms.node n
            JOIN cms.node_field_data nfd
                ON n.nid = nfd.nid
                    AND n.langcode = nfd.langcode
                    AND n.type = nfd.type
            JOIN cms.ten_cache_property_location_vicinity cplv
                ON n.nid = cplv.property_nid
            JOIN cms.node__field_propertyreferenceid nfpr
                ON n.nid = nfpr.entity_id
            LEFT JOIN cms.node__field_star_rating nfsr
                ON n.nid = nfsr.entity_id
                    AND n.langcode = nfsr.langcode
                    AND n.type = nfsr.bundle
            LEFT JOIN cms.taxonomy_term_field_data ttfd
                ON nfsr.field_star_rating_target_id = ttfd.tid
                    AND ttfd.default_langcode = 1
                    AND ttfd.`status` = 1
            LEFT JOIN cms.node__field_benefit_included nfbi
                ON n.nid = nfbi.entity_id
                    AND n.langcode = nfbi.langcode
                    AND n.type = nfbi.bundle
            WHERE nfd.`status` = 1
                AND n.type = 'accommodation'
                AND cplv.vicinity = 1;
            ";

           
            var queries = new Dictionary<string, string>();
            queries.Add("CMS/Travel_Locations.sql", qryTravelLocation);
            queries.Add("CMS/Hotels.sql", qryHotels);

            const string bucket = "<<BucketName>>";

            foreach (KeyValuePair<string, string> query in queries)
            {
                try
                {
                    UploadToS3(context, bucket, String.Format("{0}", query.Key), query.Value.ToStream(), false);
                }
                catch (Exception ex)
                {
                    context.Logger.LogLine(string.Format("An error occured writing the query {0}, to bucket {1}"
                            , query.Key, bucket));
                    context.Logger.LogLine(ex.ToString());
                }
                
            }


            foreach (KeyValuePair<string, string> query in queries)
            {
                DataTable tempTable = new DataTable();

                string connStr = "server=" +
                    "endpoint;" +
                    "user=master;database=databasename;" +
                    "port=3306;password=password";
                using (MySqlConnection conn = new MySqlConnection(connStr))
                {
                    try
                    {
                        conn.Open();
                        MySqlCommand cmd = new MySqlCommand(query.Value, conn);
                        MySqlDataReader rdr = cmd.ExecuteReader();
                        tempTable.Load(rdr);
                    }
                    catch (Exception ex)
                    {
                        context.Logger.LogLine(string.Format("An error occured executing the query {0}"
                            , query.Key));
                        Console.WriteLine(ex.ToString());
                    }

                    UploadToS3(context
                        , bucket
                        , query.Key
                        , tempTable.ToCSV().ToStream()
                        , true);
                }
            }

            return "OK";

        }

        public static bool UploadToS3(ILambdaContext context, string bucketName
            , string key
            , Stream stream
            , bool appendDate
            , string fileExtension = ".csv")
        {
            string datetime = DateTime.UtcNow.ToString("yyyyMMddhhmmss");
            string keyName = String.Empty;
            if (appendDate)
            {
                keyName = string.Format("{0}_{1}{2}", key, datetime, fileExtension);
            }
            else
            {
                keyName = key;
            }

            try
            {
                var putRequest = new PutObjectRequest
                {
                    BucketName = bucketName,
                    Key = keyName,
                    ContentType = "text/plain"
                };
                putRequest.InputStream = stream;
                var S3Client = new AmazonS3Client(Amazon.RegionEndpoint.EUWest1);
                var putObjectResponse = S3Client.PutObjectAsync(putRequest).Result;
            }
            catch (Exception ex)
            {
                context.Logger.LogLine(ex.Message);
                context.Logger.LogLine(String.Format("Unable to write to file {0}, to bucket {1}.", keyName , bucketName));
                context.Logger.LogLine(ex.ToString());
                return false;
            }
            return true;
        }
    }
}
