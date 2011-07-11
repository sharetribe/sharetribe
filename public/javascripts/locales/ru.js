function translate_validation_messages() {
  jQuery.extend(jQuery.validator.messages, {
      required: "Это поле необходимо заполнить.",
      remote: "Исправьте это поле.",
      email: "Введите корректный адрес email.",
      url: "Введите корректный URL.",
      date: "Введите корректную дату.",
      dateISO: "Введите корректную дату (ISO).",
      number: "Введите корректное число.",
      digits: "Вводите только цифры.",
      creditcard: "Введите корректный номер кредитной карты.",
      equalTo: "Введите то же значение снова.",
      accept: "Введите значение с корректным расширением.",
      maxlength: jQuery.validator.format("Вводите не более {0} символов."),
      minlength: jQuery.validator.format("Введите как минимум {0} символов."),
      rangelength: jQuery.validator.format("Введите значение длиной от {0} до {1} символов."),
      range: jQuery.validator.format("Введите значение между {0} и {1}."),
      max: jQuery.validator.format("Введите значение меньшее, или равное {0}."),
      min: jQuery.validator.format("Введите значение большее, или равное {0}.")
  });
}

function please_wait_string() {
  return "Подождите...";
}

