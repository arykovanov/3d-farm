return function(gpio)
  local pin <close> = esp32.gpio(gpio,"OUT")
  function switch(value)
    pin:value(value)
  end
end
