from cmath import pi
import json
import urllib.parse
import uuid
import boto3
import piexif
import os
import uuid

def lambda_handler(event, context):

    try:
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')

        s3 = boto3.client('s3')
        s3.download_file(bucket, key, "/tmp/{}".format(key))


    except Exception as e:
        print(e)

    try: 
        piexif.remove("/tmp/{}".format(key))
        s3.upload_file("/tmp/{}".format(key),'bucketB',key)
        # for ifd in ("0th", "Exif", "GPS", "1st"):
        #     for tag in exif_dict[ifd]:

        #         key = piexif.TAGS[ifd][tag]["name"]
        #         value = exif_dict[ifd][tag]
                
        #         try:
        #             value = value.decode('utf-8')
        #             new_item[key] = value
        #         except AttributeError as e:
        #             new_item[key] = str(value)
        #             print("{} - {} - {}".format(key, value, e))
        #             pass
        #         except UnicodeDecodeError as e: 
        #             print("{} - {} - {}".format(key, value, e))
        #             pass
    
        # print(new_item)
        # table.put_item(Item=new_item)

    except Exception as e:
        print(e)