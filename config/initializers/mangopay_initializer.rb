MangoPay.configure do |c|
    c.preproduction = true
    c.partner_id = APP_CONFIG.mangopay_partner_id
    c.key_path = APP_CONFIG.mangopay_key_path
    c.key_password = ''
end
