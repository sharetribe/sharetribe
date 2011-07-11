function translate_validation_messages() {
	jQuery.extend(jQuery.validator.messages, {
		required: "Tämä on pakollinen kenttä.",
		remote: "Kentän arvo on virheellinen.",
		email: "Anna toimiva sähköpostiosoite.",
		url: "Anna oikeanlainen URL-osoite.",
		date: "Anna päivämäärä oikessa muodossa.",
		dateISO: "Anna päivämäärä oikeassa muodossa (ISO).",
		number: "Annetun arvon pitää olla numero.",
		digits: "Tähän kenttään voit syöttää ainoastaan kirjaimia.",
		creditcard: "Anna oikeantyyppinen luottokortin numero.",
		equalTo: "Antamasi arvot eivät täsmää.",
		accept: "Kuvatiedosto on vääräntyyppinen. Sallitut tiedostomuodot: JPG, PNG ja GIF.",
		captcha: "Captcha ei ollut oikein. Yritä uudestaan.",
		maxlength: $.validator.format("Voit syöttää tähän kenttään maksimissaan {0} merkkiä."),
		minlength: $.validator.format("Syötä tähän kenttään vähintään {0} merkkiä."),
		rangelength: $.validator.format("Merkkimäärän tulee olla välillä {0} ja {1}."),
		range: $.validator.format("Kentän arvon tulee olla välillä {0} ja {1}."),
		max: $.validator.format("Arvo voi olla enintään {0}."),
		min: $.validator.format("Arvon täytyy olla vähintään {0}."),
		min_date: "Ilmoituksen viimeinen voimassaolopäivä ei voi olla aikaisempi kuin nykyhetki."
	});
}

function please_wait_string() {
  "Odota hetki..."
}