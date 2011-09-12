# BuzzData Ruby Client Library

## Getting Started

Create an instance of the Buzzdata client:

    >> buzzdata = Buzzdata.new('YOUR_API_KEY')

To make it even simpler, if you create a file, `config/buzzdata.yml` with your `api_key` in it, you can omit the key parameter:

    >> buzzdata = Buzzdata.new


## Downloading Data

To download data from a dataset, just do this:

    >> buzzdata.download_data 'eviltrout/b-list-celebrities'

## Uploading Data

If your account has the ability to upload data to a dataset, you can do so like this:

    >> buzzdata.upload_data 'eviltrout/b-list-celebrities', File.new('datasets/celebrities.csv')


# BuzzData API 

The BuzzData API returns results in JSON.

You must attach your API key as either a query parameter or post variable in the form of: api_key=YOUR_KEY.
For example, to test if your API key works, try this url:

    https://buzzdata.com/api/test?api_key=YOUR_KEY
  
You should get back a JSON object with your username in it, confirming that the key is yours and has 
authenticated properly.

## Downloading Data

Before you can download data, you need to create a `download_request`. If successful you will be given a
url to download the data from.

POST https://buzzdata.com/api/:username/:dataset/download_request

POST Parameters:

* api_key = your API key
* version = the version of the dataset you wish to download

Returns JSON:

    {download_request: {path:'PATH_TO_DOWNLOAD_YOUR_DATA'}}
  
You can then perform a GET to download the data from the path you are given.

## Upload Requests

Before you can upload data to the system, you need to create an `upload_request`. An upload request
tells you the HTTP end point your upload should be going to, as well as an `upload_code` you should
pass along with your upload to verify it.

POST https://buzzdata.com/api/:username/:dataset/upload_request

`:username` is your username: ex: 'eviltrout'
`:dataset` is the short name (url name) of the dataset you are uploading to. For example: 'b-list-celebrities'

POST Parameters:

* api_key = your API key

Returns JSON:

    {upload_request: {upload_code: 'SOME_CODE_HERE', url: 'URL_TO_UPLOAD_TO'} }

## Performing an Upload

After creating an `upload_request`, you can then POST your data file to be ingested. To do this,
send a POST request to the `url` you received in your `upload_request` JSON.

note: Make sure your POST is a multipart, otherwise the file upload will not work.

POST Parameters:

* upload_code = the `upload_code` returned in the `upload_request`
* file = the file data you are uploading to be ingested

Returns JSON:

    [{"name"=>"kittens_born.csv", "size"=>187, "job_status_token"=>"a24b2155-e2ec-48d4-8bc0-f77e3758966f"}]

`name` is the filename of the upload.
`size` is the size of the upload in bytes
`job_status_token` is an important 

## Checking your Upload Status

After a file has been uploaded, you can check out the upload's status by making a GET to:

GET https://buzzdata.com/api/:username/:dataset/upload_request/status

`:username` is your username: ex: 'eviltrout'
`:dataset` is the short name (url name) of the dataset you are uploading to. For example: 'b-list-celebrities'

GET Parameters:

* api_key = your API Key
* job_status_token = The job status token you received when you performed your upload.

Returns JSON:

    {"message"=>"Ingest Job Created", "status_code"=>"created"}

`message` is a textual description of the current status, or an error message in the event of an error
`status_code` is the status of the current job. The job has finished when it is `complete` or `error`.

Important! You should wait a little while between polls to the job status. We recommend sleeping for
one second in most cases.

Note: If you receive a status of 'Unknown' it means the file has not begun processing yet. If you 
continue to poll it will move to 'created'
