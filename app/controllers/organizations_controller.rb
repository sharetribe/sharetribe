# encoding: UTF-8

# This class is currently used by only one specific client
# The plan is to separate this code later to a plugin

class OrganizationsController < ApplicationController

  skip_filter :dashboard_only
  skip_filter :cannot_access_without_joining, :only => [:new, :create]
  skip_filter :check_email_confirmation, :only => [:new, :create]
  
  before_filter :ensure_organization_admin, :except => [:new, :create, :index]
  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_this_page")
  end
  
  EXAMPLE_MAIL_CONTENT = <<MESSAGE
Hei!

--
HUOM!

TÄMÄ ON VAIN ESIMERKKI VIESTI SIITÄ, MILLAISEN SÄHKÖPOSTIN SAAT KUN REKISTERÖIT ORGANISAATIOSI MYYJÄKSI OIKEASSA MPANKISSA (www.mpankki.fi). NYT VIRALLISTA REKISTERÖITYMISTÄ CHECKOUT FINLAND JÄRJESTELMÄÄN EI OLE TEHTY. KUN SUORITAT REKITERÖITYMISEN VARSINAISESSA PALVELUSSA, SAAT ALLA OLEVAN KALTAISEN SÄHKÖPOSTIN JA VOIT TOIMIA SEN OHJEIDEN MUKAAN

--

Olet rekisteröinyt yrityksenne mpankki.fi-palvelussa myyjäksi. Voit luoda myynti-ilmoituksen heti, mutta myyntitapahtuman tilitys voidaan suorittaa yrityksellenne vasta kun sähköinen allekirjoitus on suoritettu alla olevien ohjeiden mukaan. Tämä toimenpide tehdään vain kerran ja perustuu lakiin maksunvälityspalveluista.

Sähköisen allekirjoituksen voi tehdä ainoastaan henkilö, jolla on yrityksenne nimenkirjoitusoikeus. Jos sinulla ei ole nimenkirjoitusoikeutta, pyydämme lähettämään tämän sähköpostiohjeen yrityksenne nimenkirjoitusoikeuden omaavalle henkilölle.

Sähköisen allekirjoituksen voi suorittaa joko mobiilivarmenteella (aktivoitava teleoperaattorilla) tai verkkopankkitunnuksilla. On huomattava, että allekirjoituksella tunnistetaan henkilö, ei yritystä. Tämän vuoksi yrityksen verkkopankkitunnukset eivät ole hyväksyttävä tapa suorittaa e-allekirjoitusta, vaan on käytettävä henkilökohtaisia verkkopankkitunnuksia.

Mpankki.fi-palvelun maksunvälityspalvelun tarjoaja on Checkout Finland Oy, joka on finanssivalvonnan alaisuudessa toimiva maksunvälittäjä. Yrityksestänne annettavat tiedot tallennetaan vain Checkout Finland Oy:n rekistereihin, eikä niitä saa luovuttaa muille osapuolille, kuten mpankki.fi-palvelulle.

Sähköinen allekirjoitus suoritetaan Checkout Finland Oy:n sivulla (OIKEA VIESTI SISÄLTÄÄ LINKIN JONKA KAUTTA ALLEKIRJOITUKSEN PÄÄSEE TEKEMÄÄN)

Ennen kun kirjaudut osoitteeseen, varmistaudu että sinulla on saatavilla seuraavat tiedot:
  - Yrityksen tilinumero (IBAN), johon tilitykset ohjataan
  - Yrityksen omistajien nimet, henkilötunnukset ja omistusosuudet niistä osakkaista, jotka omistavat vähintään 25% osuuden yrityksestä (laki velvoittaa keräämään nämä tiedot, lisätietoja Checkout Finland Oy:n sivuilta)

Extranet -tunnuksenne:
Osoite: (katso tämä sitten oikean rekisteröitymisen yhteydessä tulevasta viestistä)
Asiakastunnuksenne: (katso tämä sitten oikean rekisteröitymisen yhteydessä tulevasta viestistä)
Salasananne:(katso tämä sitten oikean rekisteröitymisen yhteydessä tulevasta viestistä)

  Ystävällisin terveisin, 
  Mpankki-tiimi
  palaute@mpankki.fi
  
MESSAGE
  
  
  def index
    @selected_tribe_navi_tab = "members"
    params[:page] = 1 unless request.xhr?
    @organizations = Organization.order("id DESC").paginate(:per_page => 15, :page => params[:page])
    request.xhr? ? (render :partial => "additional_organizations") : (render :action => :index)
  end
  
  def new
    @organization = Organization.new
    @organization.email = @current_user.email
    @organization.phone_number = @current_user.phone_number
    @organization.address = @current_user.street_address
  end
  
  def create
    @organization = Organization.new(params[:organization])
    if @organization.merchant_registration == "true" && @organization.valid?
      if merchant_registration(@organization)
        # registration went ok
      else
        render action: "new" and return
      end
    end

    if @current_user && @organization.save
      membership = OrganizationMembership.create!(:person_id => @current_user.id, :organization_id => @organization.id)
      membership.update_attribute(:admin, true)
      flash[:notice] = t("organizations.new.organization_created")
      redirect_to person_path(@current_user) and return
    else
      flash.now[:error] = @organization.errors.full_messages
      render action: "new" and return
    end
  end
  
  # currently used only for testing
  def show
    @organization = Organization.find(params[:id])
  end
  
  def edit
    @organization = Organization.find(params[:id])
  end
  
  def update
    @organization = Organization.find(params[:id])
    if @organization.update_attributes(params[:organization])
      
      if @organization.merchant_registration == "true" && @organization.valid?
        if merchant_registration(@organization)
          # registration went ok
        else
          render action: "edit" and return
        end
      end
      
      flash[:notice] = t("organizations.form.changes_saved")
      #redirect_to @organization
      #render action: "edit" 
      redirect_to person_path(@current_user)
    else
      flash.now[:error] = @organization.errors.full_messages.to_s
      render action: "edit" 
    end
  end
  
  private
  
  # Deprecated
  def merchant_registration(org)
    # Check if any params missing
    if (org.email.blank? ||
        org.phone_number.blank? || 
        org.address.blank? || 
        org.website.blank?)
      flash.now[:error] = t("organizations.form.fill_in_all_details")
      return false
    end
    # save details to the user too, if he doesn't have those filled yet
    @current_user.phone_number ||= params[:phone_number]
    unless @current_user.location
      l = Location.new(:address => params[:address])
      l.search_and_fill_latlng
      l.save
      @current_user.location = l
    end
    
    if org.register_a_merchant_account
      if APP_CONFIG.merchant_registration_mode == "stub"
        PersonMailer.open_content_message(@current_user, "ESIMERKKIVIESTI: Tervetuloa Checkout -palvelun kauppiaaksi", EXAMPLE_MAIL_CONTENT).deliver
      end
      return true
    else
      flash.now[:error] = t("organizations.form.error_with_organization_registration")
      return false
    end
  end
  
  def ensure_organization_admin
    Organization.find(params[:id]).has_admin?(@current_user)
  end
end
