using Flux, Images, BSON, MLUtils, Genie, Genie.Router, Genie.Requests
Genie.config.run_as_server = true
Genie.config.cors_allowed_origins = ["*"]
function recognizeDigit(img)
    # load the model
    BSON.@load "digits.bson" model
    # Convert image to grayscale
    img = Gray.(img)
    # Invert each pixel color
    img = (x->Gray(1)-x.val).(img)
    # resize image to 28x28 pixels
    img = imresize(img,(28,28))
    # Get matrix of image
    digit_data = Float32.(channelview(img))
    # predict the digit (get probabilities)
    probs = model(cat(digit_data,dims=4))
    # return the digit with the largest 
    # probability, converted to a string
    return "$(argmax(probs)[1]-1)"
end

route("/api/recognize", method=POST) do
    @show jsonpayload()
    @show rawpayload()
    result = ""
    files = filespayload();   
    for index in 1:11
        file = files["$index.png"]
        img = load(IOBuffer(file.data))
        result *= recognizeDigit(img)        
    end    
    return result
end

route("/") do 
    String(read("index.html"))
end

up(8080, async=false)