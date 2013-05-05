en_subject = "Help us make Sharetribe better"
en_message = <<MESSAGE
I’m writing to you because you have recently started a new Sharetribe for your community. Great to have you on board! 

We at Sharetribe are working constantly to make the service better for all kinds of communities around the world. To do that, we’d like to get your feedback. 

If you have 15-30 minutes at some day, I would much like to chat with you on Skype or Google Hangout. It would be really helpful to get a chance to talk to you and hear about your wishes and expectations towards Sharetribe. It doesn’t matter if you haven’t invited any of your friends to the community yet or if you just created it for test purposes, I’d love to have a chat anyway. 

If you would be able to chat, please reply to this email.

If you have any questions or troubles regarding the service and how to invite your community to use it, I'm here to help you. Just reply to this email and I’ll get back to you as soon as I can. You can also get real time help from our free Help & Support chatroom. Join here: https://sharetribe.flowdock.com/invitations/dd71aff8775de59782a6acaa3889298b37b26065-help-support

Thanks a lot!

Best Regards,
Juho Makkonen
Co-Founder & CEO, Sharetribe
MESSAGE

fi_subject = "Auta meitä tekemään Sharetribesta parempi"
fi_message = <<MESSAGE
Olet vastikään perustanut Sharetriben omalle yhteisöllesi. Hienoa!

Me Sharetribessa työskentelemme jatkuvasti sen eteen, että palvelu vastaisi mahdollisimman hyvin erilaisten yhteisöjen tarpeita. Haluaisimmekin nyt kuulla palautettasi palvelusta.

Jos sinulla on 15-30 minuuttia aikaa lähipäivinä, haluaisin mieluusti jutella kanssasi. Jos asut tai liikut silloin tällöin pääkaupunkiseudulla, voimme tavata livenä (tarjoan kahvit). Muussa tapauksessa voimme jutella esimerkiksi puhelimitse tai Skypen/Google Hangoutin välityksellä. Ei haittaa, vaikka perustamassasi yhteisössäsi ei ole vielä yhtään jäsentä tai jos olet perustanut sen vain testimielessä - palaute on silti tervetullutta! 

Jos siis lyhyt keskustelutuokio sopii, kerrothan siitä vastaamalla tähän viestiin.

Jos sinulla on mitä tahansa kysyttävää Sharetribeen liittyen tai haluat antaa palautetta, autan myös mielelläni. Vastaa vain tähän viestiin ja palaan asiaan niin pian kuin mahdollista. Reaaliaikaista apua saa myös Sharetriben ilmaiselta web-selaimessa toimivalta chat-kanavalta, johon voit liittyä seuraavan linkin kautta: https://sharetribe.flowdock.com/invitations/dd71aff8775de59782a6acaa3889298b37b26065-help-support

Kiitos paljon!

Terveisin,
Juho Makkonen
Toimitusjohtaja ja perustajatiimin jäsen, Sharetribe
MESSAGE

mail_content = {
  "en"=>{
    "body"=> en_message, 
    "subject"=> en_subject}, 
  "fi"=>{
    "body"=> fi_message,
    "subject"=> fi_subject}
 }

# c = Community.all_admins
# # # PersonMailer.deliver_open_content_messages(test_array, "test subject", mail_content, "en", true)
# PersonMailer.deliver_open_content_messages(c, "Help us make Sharetribe better", mail_content, "en", true)