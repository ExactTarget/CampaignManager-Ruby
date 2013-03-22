CampaignManager
==============
The CampaignManager application illustrates how to utilize the ExactTarget Fuel SDK for Ruby which is used to access both REST and SOAP services.  

###Overview###
Page 1: Create a Campaign - This is the first page that will be presented.  It allows new Campaigns to be created, after creating a new campaign or selecting an existing on from the left navigation it will redirect to the Campaign Details page. 
![](http://image.exct.net/lib/fe6c15707760067d7112/m/1/CampaignManager+-+Create+New.png)

Page 2: Campaign Details - Displays details about the campaign and related items called assets.  Assets can be a variety of different items within ExactTarget including but not limited to Emails, Lists, TriggeredSend, and Sends.
![](http://image.exct.net/lib/fe6c15707760067d7112/m/1/CampaignManager+-+Details.png)

##Objects Used###
- ET_Campaign - Represents a Campaign within ExactTarget's Interactive Marketing Hub.  Uses the [Campaigns](https://code.exacttarget.com/devcenter/fuel-api-family/hub/campaigns) resource in Fuel API (REST). 
- ET_Email - Represents an Email object with ExactTarget.  Uses the [Email](http://help.exacttarget.com/en/technical_library/web_service_guide/technical_articles/retrieving_an_email_via_the_soap_api/) object in the SOAP API
- ET_List - Represents an List object with ExactTarget which is a collection of subscribers that can be used as an audience for a send. Uses the [List](http://help.exacttarget.com/en/technical_library/web_service_guide/technical_articles/retrieving_a_list_from_an_account/) object in the SOAP API.
	
##Requirements##
Ruby Version 1.9.3

###Gems###
####Required####
- Bundler

####Included in Bundle####
- rack
- sinatra 
- sinatra-contrib 
- thin
- savon
- jwt
- mongo
- bson_ext
- mongo_mapper
- haml
- sass
- maruku
- rack-flash
- json
- spawn, 0.1.3
- quietbacktrace
- faker, 0.3.1
- contest, 0.1.2
- override, 0.0.10
- rack-test, 0.5.3
- stories, 0.1.3
- webrat, 0.7.0


##Recommendation##
In order to easily be able to work with multiple versions of Ruby or working with Ruby projects that have specific Gem requirements, we recommend using [Ruby Version Manager (RVM)](https://rvm.io/)

- Visit [https://rvm.io/] (https://rvm.io/) in order to obtain install instructions 
- After installed installed the ruby version needed for this project
>$ rvm install 1.9.3

- Set this to the Ruby version to use and create a Gemset specific to Campaign Manager
>$ rvm use 1.9.2-head@campmanager --create

These steps will need to be completed prior to continuing to setup. 

If you are using Windows then [Pik](https://github.com/vertiginous/pik) provides similar functionality. 

##Setup##
After confirming you have bundler Gem installed, run the following:
> $ bundle install

Rename config.yaml.template to config.yaml. Replace the value for clientid and clientid with the values from App Center. If you have not received your keys, please visit [App Center](https://code.exacttarget.com/appcenter).   For more information on App Center, please see the [Dev Center](https://code.exacttarget.com/devcenter/getting-started/app-center-overview) documentation. 

Start the localhost server
> $ rackup config.ru

Access the site in your browser:
>http://localhost:9292/login

###Breakdown###

####Login Processing (route: '/login') 
The ET\_Client is instantiated and stored as a session variable so we can utilize the same ET_Client for all calls using the SDK.  
<pre>
<code>
get '/login' do
	if !session.has_key?(:authstub) then
		session[:authstub] = ET_Client.new
	end
	redirect '/'
end	
</code>
</pre>

####Step 1 (route: '/') 
The HAML templates are setup so that the left navigation is setup to display a list of all of the Campaigns so they can be selected in order to see more details. This utilizes the ET_Campaign SDK object with the Get method.  Also being hardcoded are the colors that will be selectable in a dropdown on the page. See the HAML template for more details on how it uses the instance variables for @camps and @colors.
<pre><code>
# Located in app\routes\site.rb
get '/' do		
	# Retrieve the campaigns for the left nav
	camp = ET_Campaign.new
	camp.authStub = session[:authstub]		
	campResponse = camp.get
	#p campResponse
	@camps = campResponse.results['items']
	
	# Define Colors for the Form's Drop Down
	@colors = [	'D1EE68','CFBA31','23B049','E25822','F0A94E','EDEE68','E02516','F59682']
	
	haml :'pages/home'
end</code></pre>


####Step 2 (POST route: '/campaign') 
Next, we are going to setup a route to handle the form post for creating a new Campaign. Again we will be using the ET_Campaign object but now using the Post method. The form has been setup so that the field names match with the values expected by the Post method so we can just pass them directly in. 
<pre><code>
# Located in app\routes\site.rb
post '/campaign' do						
	postParams = request.POST				
	newCampaign = ET_Campaign.new
	newCampaign.authStub = session[:authstub]
	# Pass through the post parameters exactly as they were passed from the form
	newCampaign.props = params
	postResponse = newCampaign.post
	p postResponse
	
	if postResponse.status then 
		newID = postResponse.results['id']
		redirect "/campaign/#{newID}"
	end 
end
</code></pre>

####Step 3 (route: '/campaign/:id') 
This step involves gathering all of the necessary data to display the Campaign Details page which includes details about the campaign along with the ability to add an existing email or a list as a campaign asset. First the ET\_Campaign object is used with the Get method to populate the left nav identical to what we did in Step 1.  We utilize the ET\_Campaign object again with the Get method a second time but we are also setting the props property in order to define the specific Campaign we want instead of getting a list of all. Lastly, the Asset object nested under ET\_Campaign is used to get all of the currently associated assets using the Get method. 
<pre><code>
# Located in app\routes\site.rb
get '/campaign/:id' do
	# Retrieve the campaigns for the left nav
	camp = ET_Campaign.new
	camp.authStub = session[:authstub]		
	campResponse = camp.get
	p campResponse
	@camps = campResponse.results['items']
	
	# Retrieve the campaign details for the selected campaign
	@campaign = {}		
	camp = ET_Campaign.new
	camp.authStub = session[:authstub]
	camp.props = {'id' => params[:id]}		
	campResponse = camp.get		
	p campResponse
	@campaign['details'] = campResponse.results
			
	# Retrieve the assets related to the selected campaign
	campAsset = ET_Campaign::Asset.new
	campAsset.authStub = session[:authstub]
	campAsset.props = {'id' => params[:id]}		
	assetResponse = campAsset.get
	p assetResponse		
	@campaign['assets'] = assetResponse.results['entities']
	
	haml :'pages/get_campaign'
end	
</code></pre>

####Step 4 (route: '/assets/:type') 
In order for the Campaign Details page to function correctly, it needs to be able to populate the drops downs for selecting existing assets(such as email or list) in order to relate them to the campaign.  The following will provide an endpoint that can be consumed using an AJAX request to populate the dropdown the the appropriate type of asset. This will use the ET\_List object and the ET\_Email object, both the the Get method.  The response is translated into JSON in order to make it easy to consume in Javascript.

<pre><code>
# Located in app\routes\site.rb
get '/assets/:type' do
	getObj = {}

	if params[:type] == "list" then 
		#Get All of the Lists
		getObj = ET_List.new()
		getObj.props = ["ID","ListName"]				
	elsif params[:type] == "email"		
		#Get All of the Emails
		getObj = ET_Email.new()
		getObj.props = ["ID","Name"]						
	end 

	getObj.authStub = session[:authstub]
	getObjResponse = getObj.get
	p getObjResponse	
	
	getObjResponse.to_json		
end		
</code></pre>


####Step 5 (POST route: '/campaignAsset') 
The final piece needed for the CampaignManager is handling the form post for adding new campaign assets.  This function will utilize the Asset object nested under ET\_Campaign with the Get method to add the association. In the form handler for creating a campaign, the form fields do not match with the values expected by the SDK so the requestObject variable is used to build out the request.  

<pre><code>
# Located in app\routes\site.rb
post '/campaignAsset' do
	body = request.body.read
	assetDetails = JSON.parse(body)
	
	requestObject = {}
	requestObject['id'] = assetDetails['CampaignID']
	requestObject['ids'] = [assetDetails['ItemID']]
	requestObject['type'] = assetDetails['Type']
	
	campAsset = ET_Campaign::Asset.new
	campAsset.authStub = session[:authstub]
	campAsset.props = requestObject
	postResponse = campAsset.post	
	p postResponse	
	
	postResponse.to_json		
end		
</code></pre>
