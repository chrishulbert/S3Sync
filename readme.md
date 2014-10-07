# S3Sync

Synchronise a folder to Amazon S3. Mainly intended for uploading your Jekyll site. Will only upload files that have changed in size or md5 hash.

I created this because ruby's jekyll-s3 is very slow and was recently forked, and the forked version has issues of its own.

This app will upload 4 files at a time, and is lightning quick in my tests. 223 changed files took less than a minute, whereas jekyll-s3 took forever (sometimes 15 mins).

## Config

To use the app, you need a file called `S3Sync.config.json` in your home folder, with the following contents:

	{
		"AccessKeyID": "ABC123",
		"Secret": "BLAHBLAH",
		"Bucket": "www.myamazons3bucket.com.au",
		"Region": "s3.amazonaws.com",
		"LocalFolder": "~/My/Jekyll/_site"
	}
