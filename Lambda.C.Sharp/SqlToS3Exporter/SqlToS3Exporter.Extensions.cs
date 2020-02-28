using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Data;
using System.Text.RegularExpressions;

namespace SqlToS3Exporter
{
    static class Extensions
    {
        public static Stream ToStream(this String str)
        {
            var stream = new MemoryStream();
            var writer = new StreamWriter(stream);
            writer.Write(str);
            writer.Flush();
            stream.Position = 0;
            return stream;
        }

        public static string ToCSV(this DataTable dtDataTable, string delimiter = ",")
        {
            StringBuilder stringBuilder = new StringBuilder();
            for (int i = 0; i < dtDataTable.Columns.Count; i++)
            {
                stringBuilder.Append(dtDataTable.Columns[i]);
                if (i < dtDataTable.Columns.Count - 1)
                {
                    stringBuilder.Append(string.Format("{0} ", delimiter));
                }
            }

            stringBuilder.AppendLine();
            foreach (DataRow dr in dtDataTable.Rows)
            {
                for (int i = 0; i < dtDataTable.Columns.Count; i++)
                {
                    if (!Convert.IsDBNull(dr[i]))
                    {
                        //char leftDoubleQuote = '\u201c';
                        //char rightDoubleQuote = '\u201d';
                        string value = dr[i].ToString();
                        //if (value.Contains(delimiter) | value.Contains(leftDoubleQuote) | value.Contains(rightDoubleQuote) | value.Contains("\""))
                        if (value.Contains(delimiter))
                        {
                            // = value.Replace('\u201c', '\"').Replace('\u201d', '\"');
                            //value = value.Replace("\"", "\"\"");
                            //value = String.Format("\"{0}\"", value);
                            value = Regex.Replace(value, @"\|", " ");
                            stringBuilder.Append(value);
                        }
                        else
                        {
                            stringBuilder.Append(dr[i].ToString());
                        }
                    }
                    if (i < dtDataTable.Columns.Count - 1)
                    {
                        stringBuilder.Append(delimiter);
                    }
                }
                stringBuilder.AppendLine();
            }
            return stringBuilder.ToString();
        }

        public static void Fill(this DataTable table, IDataReader reader, bool createColumns)
        {
            if (createColumns)
            {
                table.Columns.Clear();
                var schemaTable = reader.GetSchemaTable();
                foreach (DataRowView row in schemaTable.DefaultView)
                {
                    var columnName = (string)row["ColumnName"];
                    var type = (Type)row["DataType"];
                    table.Columns.Add(columnName, type);
                }
            }
            table.Load(reader);
        }
    }
}
