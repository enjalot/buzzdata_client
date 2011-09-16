# BuzzData Ruby Client Library

## Getting Started

Create an instance of the Buzzdata client:

    >> buzzdata = Buzzdata.new('YOUR_API_KEY')

To make it even simpler, if you create a file, `config/buzzdata.yml` with your `api_key` in it, you can omit the key parameter:

    >> buzzdata = Buzzdata.new


## Downloading Data

To download data from a dataset, just do this:

    >> buzzdata.download_data 'eviltrout/b-list-celebrities'

## Dataset Information

Using `dataset_overview` you can get an overview of a Dataset's information. It returns a hash of attribute names and their values. See the *API Documentation* below for a list of the returned attributes.

    >> ds = buzzdata.dataset_overview 'eviltrout/b-list-celebrities'
    >> puts ds['name']  # outputs B-List Celebrities


## Creating a Dataset

You can use the `create_dataset` method to create a new dataset. All fields are required:

    >> ds = buzzdata.create_dataset(:username => 'eviltrout',
                                    :name => "My Awesome Dataset!",
                                    :public => false,
                                    :readme => "This is my awesome dataset",
                                    :license => 'cc0',
                                    :topics => ['testing-buzzdata'])  

    >> puts ds['id']     # outputs eviltrout/my-awesome-dataset

## Uploading Data

If your account has the ability to upload data to a dataset, you can do so like this:

    >> upload = buzzdata.start_upload('eviltrout/b-list-celebrities', File.new('datasets/celebrities.csv')

Uploads take some time to be processed. You can poll how the processing is going using `in_progress?`

    >> upload.in_progress?   # true - upload is going on

    (wait for some time to pass..)

    >> upload.in_progress?   # false - upload is done!

For a more thourough example of this, look at the sample in *samples/upload_data.rb*


## Get a list of usable Licenses 

    >> buzzdata.licenses

  

# BuzzData API 

The BuzzData API returns results in JSON.

You must attach your API key as either a query parameter or post variable in the form of `api_key=YOUR_KEY`.

For example, to test if your API key works, try this url:

    https://buzzdata.com/api/test?api_key=YOUR_KEY
  
You should get back a JSON object with your username in it, confirming that the key is yours and has authenticated properly.

## Rate Limits

The API currently limits the requests you can make against it hourly. If you need more requests than that, please contact us and we'll let you know.

We have provided two response headers with each request to the API with Rate Limiting Information. They are returned from every API call.

    X-RateLimit-Limit: 5000
    X-RateLimit-Remaining: 4998

`X-RateLimit-Limit` is your current limit per hour. `X-RateLimit-Remaining` is how many requests you have left.

# Datasets

## Dataset Details (Overview)

To retrieve information about a dataset, simply make a GET:

**GET https://buzzdata.com/api/:username/:dataset**

**GET Parameters:**

* `api_key` = your API Key

**Returns JSON:**

    {"dataset":
      {"id":"eviltrout/b-list-celebrities",
       "username":"eviltrout",
       "shortname":"b-list-celebrities",
       "name":"B-List Celebrities",
       "readme":"Here's a list of B-List Celebrities that I've curated.",
       "public":true,
       "license":"cc0",
       "published":true,
       "created_at":"2011-07-12T14:31:21-04:00",
       "data_updated_at":"2011-07-12T14:41:52-04:00"}}

## Downloading Data

Before you can download data, you need to create a `download_request`. If successful you will be given a
url to download the data from.

**POST https://buzzdata.com/api/:username/:dataset/download_request**

* `:username` is your username: ex: 'eviltrout'
* `:dataset` is the short name (url name) of the dataset you are uploading to. For example: 'b-list-celebrities'

**POST Parameters:**

* `api_key` = your API key
* `version` = the version of the dataset you wish to download

**Returns JSON:**

    {download_request: {path:'PATH_TO_DOWNLOAD_YOUR_DATA'}}
  
You can then perform a GET to download the data from the path you are given.


## Creating a Dataset

Before you can upload data to a dataset, you need to create a dataset object in our system with meta-data about the dataset. 

**POST https://buzzdata.com/api/:username/datasets**

* `:username` is your username: ex: 'eviltrout'

**POST Parameters:**

* `api_key` = your API Key
* `dataset[name]` = the name of the dataset
* `dataset[public]` = (true/false) whether the dataset is public or private
* `dataset[readme]` = the content for "About this Dataset"
* `dataset[license]` = the license the dataset is being offered with. See *Licenses* below
* `dataset[topics]` = the short names of the topics associated with this dataset

**Returns JSON:**

It returns the same output from the *Dataset Details (Overview)* above of the completed dataset, or an error message if the dataset couldn't be created.


## Upload Requests

To upload data to the system, you need to create an `upload_request`. An upload request tells you the HTTP end point your upload should be going to, as well as an `upload_code` you should pass along with your upload to verify it.

**POST https://buzzdata.com/api/:username/:dataset/upload_request**

* `:username` = your username: ex: 'eviltrout'
* `:dataset` = the short name (url name) of the dataset you are uploading to. For example: 'b-list-celebrities'

**POST Parameters:**

* `api_key` = your API key

**Returns JSON:**

    {upload_request: {upload_code: 'SOME_CODE_HERE', url: 'URL_TO_UPLOAD_TO'} }

* `upload_code` = a unique token that authenticates your upload
* `url` = the endpoint for where the file should be uploaded

## Performing an Upload

After creating an `upload_request`, you can then POST your data file to be ingested. To do this, send a POST request to the `url` you received in your `upload_request` JSON.

*note: Make sure your POST is a multipart, otherwise the file upload will not work.*

**POST Parameters:**

* `api_key` = your API Key
* `upload_code` = the `upload_code` returned in the `upload_request`
* `file` = the file data you are uploading to be ingested

**Returns JSON:**

    [{"name"=>"kittens_born.csv", "size"=>187, "job_status_token"=>"a24b2155-e2ec-48d4-8bc0-f77e3758966f"}]

* `name` = the filename of the upload.
* `size` = the size of the upload in bytes
* `job_status_token` = an important 

## Checking your Upload Status

After a file has been uploaded, you can check out the upload's status by making a GET to:

**GET https://buzzdata.com/api/:username/:dataset/upload_request/status**

* `:username` = your username: ex: 'eviltrout'
* `:dataset` = the short name (url name) of the dataset you are uploading to. For example: 'b-list-celebrities'

**GET Parameters:**

* `api_key` = your API Key
* `job_status_token` = The job status token you received when you performed your upload.

**Returns JSON:**

    {"message"=>"Ingest Job Created", "status_code"=>"created"}

* `message` is a textual description of the current status, or an error message in the event of an error
* `status_code` is the status of the current job. The job has finished when it is `complete` or `error`.

Important! You should wait a little while between polls to the job status. We recommend sleeping for one second in most cases.

Note: If you receive a status of 'Unknown' it means the file has not begun processing yet. If you continue to poll it will move to 'created'

# Licenses

When creating a dataset, it is necessary to supply a valid license for the data. You can query the available licenses by:

**GET https://buzzdata.com/api/licenses**

**GET Parameters:**

* `api_key` = your API Key

**Returns JSON:**

    [
      {"id":"cc0"},
      {"id":"pdm"},
      {"id":"cc_by"}
      ...
    ]
