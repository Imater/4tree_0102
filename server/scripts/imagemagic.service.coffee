gm = require('gm').subClass({ imageMagick: true });;
fs = require('fs');

tesseract = require('node-tesseract');
guessLanguage = require('guessLanguage');

#/opt/local/bin/convert 1.jpeg \( +clone -blur 0x20 \) -compose Divide_Src -composite ocr.tif

image_service = {
  image_make_white: (img_url)->
    mythis = @;
    console.info img_url
    #'+Math.round(Math.random()*100)+'.png
    new_file_name = './user_data/1.png'

    gm(img_url)
#    .normalize()
#    .threshold('50%')
#    .autoOrient()
    .write new_file_name, (err)->
      if (!err) 
        console.log('done');
        mythis.recognize new_file_name, img_url
      else
        console.log 'ERROR = ', err
  getSize: (img_url)->
    gm(img_url).identify (err, data)->
      console.info 'size = ', data
  recognize: (img_url, old_img_url)->
    options =
      l: "rus+eng"
      psm: 1 #1 - BEST RESULT
      binary: "/opt/local/bin/tesseract"
    console.info 'start_recognize'
    tesseract.process img_url, options, (err, text) ->
      if err
        console.error err
      else
        guessLanguage.guessLanguage.detect text, (lang)->
          if ['ru', 'en', "uk", "kk", "uz", "mn", "mk", "bg", "ky"].indexOf(lang)!=-1
            console.log "------------------"+old_img_url+"---------------------"
            console.log "----------------PREPARE-----------------", text
            console.info 'LANGUAGE ok = ', lang
          else
            console.log "----------------PREPARE-----------------", text
            console.info 'LANGUAGE bad = ', lang
      return

}

module.exports = image_service