-- Creating yelp_reviews table and importing data from s3 bucket
-- staging table
create or replace table yelp_reviews (review_text variant)

COPY INTO yelp_reviews
FROM 's3://my-s3-bucket-shiff/yelp_dataset/'
CREDENTIALS = (
    AWS_KEY_ID = '****************' 
    AWS_SECRET_KEY = '*************************'
)
FILE_FORMAT = (TYPE = JSON);

-- Check the imported data
select * from yelp_reviews limit 10;

-- Creating yelp_businesses table and importing data from s3 bucket
-- staging table 
create or replace table yelp_businesses (business_text variant)

COPY INTO yelp_businesses
FROM 's3://my-s3-bucket-shiff/yelp_dataset/yelp_academic_dataset_business.json'
CREDENTIALS = (
    AWS_KEY_ID = '*******************'
    AWS_SECRET_KEY = '***************************'
)
FILE_FORMAT = (TYPE = JSON);

-- Check the imported data
select * from yelp_businesses limit 100;

-- Function for sentiment analysis
CREATE OR REPLACE FUNCTION analyze_sentiment(text STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('textblob') 
HANDLER = 'sentiment_analyzer'
AS $$
from textblob import TextBlob
def sentiment_analyzer(text):
    analysis = TextBlob(text)
    if analysis.sentiment.polarity > 0:
        return 'Positive'
    elif analysis.sentiment.polarity == 0:
        return 'Neutral'
    else:
        return 'Negative'
$$;

--Creating final tables with the required columns for analysis
--yelp_reviews
create or replace table tbl_yelp_reviews as 
select  review_text:business_id::string as business_id 
,review_text:date::date as review_date 
,review_text:user_id::string as user_id
,review_text:stars::number as review_stars
,review_text:text::string as review_text
,analyze_sentiment(review_text) as sentiments
from yelp_reviews; 

select * from tbl_yelp_reviews limit 10;

--yelp_businesses
create or replace table tbl_yelp_businesses as 
select business_text:business_id::string as business_id
,business_text:name::string as name
,business_text:city::string as city
,business_text:state::string as state
,business_text:review_count::string as review_count
,business_text:stars::number as stars
,business_text:categories::string as categories
from yelp_businesses;

select * from tbl_yelp_businesses limit 10;