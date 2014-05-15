# encoding: utf-8

en_subject = "IMPORTANT: (3nd reminder) Remember to accept Sharetribe’s new terms of use by THIS SUNDAY, or your account will be deleted!"
en_message = <<MESSAGE
This is the third (and last) reminder about the topic. If you already spotted this notice, but you don't want your data to be preserved, you don't need to do anything.

Aalto University's Sharetribe (earlier Kassi) has new Terms of Use (since spring 2011), which you have not yet accepted. September Sharetribe’s database will soon be moved to new server and the upkeep responsibility of the service will be transfered from OtaSizzle research project to Sharetribe Oy, a company founded for future development of Sharetribe. The change in the terms of use is made to allow this transfer. We cannot transfer the user accounts, who have not permitted the transfer by accepting the new terms, so we will need to delete those accounts and all the data related to them (listings, messages, feedback etc.)

You can accept the new terms easily by logging in at: https://aalto.sharetribe.com/en/login Do that by latest on ned SUNDAY 30th October, to get your data saved.

If you have forgotten your username or your password, there is a link at the login page to help you.

If you want to delete all your data in Sharetribe, you don’t need to do anything. The deletion will happen automatically at 30th September.

If you want to ask more details about the upcoming transfer or send any feedback about the service, you can reply to this email.

Best regards,
Antti Virolainen
Sharetribe team
MESSAGE


fi_subject = "TÄRKEÄ: (3. muistutus) Muista hyväksyä Aallon Sharetriben uudet käyttöehdot VIIM. SUNNUNTAINA tai käyttäjätietosi poistetaan!"
fi_message =  <<MESSAGE
Tämä on kolmas (ja viimeinen) muistutusviesti aiheesta. Jos huomasit asian jo aiemmin, mutta et halua tietojasi siirrettävän, sinun ei tarvitse tehdä mitään.

Et ole vielä hyväksynyt Aallon Sharetriben (entinen Kassi) uusia (keväällä 2011 voimaan tulleita) käyttöehtoja. Sharetriben tietokanta siirretään pian uudelle palvelimelle, ja tässä yhteydessä joudumme poistamaan kaikki ne käyttäjät, jotka eivät ole hyväksyneet uusia ehtoja, sekä näiden käyttäjien kaikki tiedot (ilmoitukset, viestit sekä saadut ja annetut palautteet). Tietojen siirto tehdään, koska Sharetribe-palvelun ylläpitovastuu siirtyy OtaSizzle-tutkimusprojektilta Sharetribe Oy -yrityksellemme. Uusien käyttöehtojen tarkoituksena on oikeuttaa meidät tekemään siirto.

Voit hyväksyä uudet ehdot klikkaamalla seuraavaa linkkiä: https://aalto.sharetribe.com/fi/login ja kirjautumalla sisään. Hyväksy ehdot sunnuntaihin 30.9. mennessä, jotta tunnuksesi säilyy.

Jos olet unohtanut käyttäjätunnuksesi tai salasanasi, linkin takaa löytyvät myös ohjeet, joilla saat ne tietoosi.

Jos haluat, että kaikki tietosi poistetaan Sharetribesta, sinun ei tarvitse tehdä mitään. Poisto tehdään automaattisesti 30.9. tai vähän sen jälkeen.

Jos haluat kysyä lisätietoja siirrosta tai antaa palautetta Sharetribestä, voit vastata suoraan tähän mailiin.

Terveisin,
Antti Virolainen
Sharetriben ylläpito
MESSAGE

mail_content = {
  "en"=>{
    "body"=> en_message,
    "subject"=> en_subject},
  "fi"=>{
    "body"=> fi_message,
    "subject"=> fi_subject}
 }

# c = Community.find_by_domain("aalto").members.where("`community_memberships`.consent = 'KASSI_FI1.0'");0
# # # PersonMailer.deliver_open_content_messages(test_array, "test subject", mail_content, "fi", true)
# PersonMailer.deliver_open_content_messages(c, "Remember to accept new terms of use in Sharetribe!", mail_content, "fi", true)