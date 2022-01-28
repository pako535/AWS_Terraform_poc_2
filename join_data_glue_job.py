import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from datetime import datetime

current_date = datetime.now()
partition_path = "year={}/month={}/day={}/hour={}/".format(current_date.year, current_date.month, current_date.day, current_date.hour)

args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Script generated for node Amazon S3
bikes_df = glueContext.create_dynamic_frame.from_catalog(
    database="biel-poc2-database",
    table_name="bikes",
    transformation_ctx="bikes_df",
)

# Script generated for node Amazon S3
history_df = glueContext.create_dynamic_frame.from_catalog(
    database="biel-poc2-database",
    table_name="history",
    transformation_ctx="history_df",
)

# Script generated for node Join
join = Join.apply(
    frame1=bikes_df,
    frame2=history_df,
    keys1=["number"],
    keys2=["numer roweru"],
    transformation_ctx="join",
)

# Script generated for node Amazon S3
write_paraquet_to_s3 = glueContext.write_dynamic_frame.from_options(
    frame=join,
    connection_type="s3",
    format="glueparquet",
    connection_options={"path": "s3://biel-poc2/paraquet/" + partition_path, "partitionKeys": []},
    transformation_ctx="write_paraquet_to_s3",
)

job.commit()
