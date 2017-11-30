function preview_image(file){
  var fr = new FileReader();
  var img = document.createElement("img");
  fr.onload = function(){
    img.src = fr.result;
    $('#preview').append(img);
  };
  fr.readAsDataURL(file);
}

$(function(){
  var file_counter = 0;
  $('input[type="file"]').change(function(){
    for(var i = 0; i < this.files.length; i++){
      preview_image(this.files[i]);
      file_counter += 1;
    }

    if(file_counter == 1){
      var chosen_file_name = $(this)[0].files[0].name;
      $('#slide_file_name_field').text(chosen_file_name);
    }else{
      $('#slide_file_name_field').text(file_counter + " files are selected");
    }

    $('#upload_confirmation_btn').prop('disabled', false);
  });

  $('.photo-wrapper').click(function(){
    if($(this).children('.photo-checker').css('display') == 'none'){
      $(this).children('.photo-content').css('opacity', '0.6');
      $(this).children('.photo-checker').show();
    }else{
      $(this).removeAttr('href download');
    }
  });
});
