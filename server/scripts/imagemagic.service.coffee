gm = require('gm').subClass({ imageMagick: true });;
fs = require('fs');
$ = require('jquery')
server = require('http').createServer()
io = require('socket.io').listen(server)

tesseract = require('node-tesseract');
guessLanguage = require('guessLanguage');

#/opt/local/bin/convert 1.jpeg \( +clone -blur 0x20 \) -compose Divide_Src -composite ocr.tif
tm = new Date().getTime();
image_service = {
  image_make_white: (img_url, socket_user_id)->
    dfd = $.Deferred()
    mythis = @;
    console.info img_url
    #'+Math.round(Math.random()*100)+'.png
    new_file_name = './user_data/1'+Math.round( Math.random()*2000 )+'.png'


    exec = require('child_process').exec
    command = [
        'convert', img_url
        "\\( +clone -blur 0x20 \\)",
        '-compose', 'Divide_Src',
        '-composite', new_file_name, 
        ];
    #making watermark through exec - child_process
    exec command.join(' '), (err, stdout, stderr)->
      if (err) 
        console.log(err)
      console.info stdout

      gm(new_file_name)
      #.type('Grayscale')
      .resize(4500,5000)
      .autoOrient()
  #    .out('rex')
      #.compose('Divide_Src')
  #    .sharpen(25,25)
      .normalize()
  #   .threshold('50%')
      .write new_file_name, (err)->
        if (!err) 
          console.log('done');
          mythis.recognize(new_file_name, img_url, socket_user_id).then (text)->
            dfd.resolve(text);
        else
          console.log 'ERROR = ', err
    dfd.promise();
  getSize: (img_url)->
    gm(img_url).identify (err, data)->
      console.info 'size = ', data
  recognize: (img_url, old_img_url, socket_user_id)->
    dfd = $.Deferred()
    options =
      l: "rus+eng"
      psm: 1 #1 - BEST RESULT
      binary: "/usr/local/bin/tesseract"
    console.info 'start_recognize'
    tesseract.process img_url, options, (err, text) ->
      if err
        console.error err
      else
        guessLanguage.guessLanguage.detect text, (lang)->
          if ['ru', 'en', "uk", "kk", "uz", "mn", "mk", "bg", "ky"].indexOf(lang)!=-1
            console.log "------------------"+img_url+"---------------------"
            console.log "----------------PREPARE-----------------", text
            console.info 'LANGUAGE ok = ', lang
            dfd.resolve(text)
          else
            console.log "----------------PREPARE-----------------", text
            console.info 'LANGUAGE bad = ', lang
            dfd.resolve(text)
          console.info 'time = ', new Date().getTime() - tm, socket_user_id.emit
          socket_user_id.emit 'file_loaded', text
      return
    dfd.promise();

}

module.exports = image_service