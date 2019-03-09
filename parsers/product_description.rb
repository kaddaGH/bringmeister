data = JSON.parse(content)
products_details = page['vars']['product_details']

description = data['data']['product']['content']['description'] rescue ''
features = data['data']['product']['features'] rescue []

description=(description.nil?)?'':description
features.each do |feature|


description = description +' . '+feature['label']+':'+feature['value']

end


availability = data['data']['product']['isAvailable'] rescue  false
availability = (availability==true)?"1":""
products_details[:PRODUCT_DESCRIPTION]=description
products_details[:IS_AVAILABLE] = availability


outputs<<products_details

