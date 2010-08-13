class Mail < ActiveRecord::Base
  
  # This is a tableless model only used for validating Contactform Fields.
  # You can specify the fields for your contactform in the config/alchemy/config.yml file in the :mailer options
  # 
  # Options:
  # --------
  # 
  # :form_layout_name: String (A PageLayout name)               Used to render the contactform on a page with this layout.
  # 
  # Fieldtypes are:
  # ---------------
  #   :string
  #   :text
  #   :boolean
  # 
  # Validating fields:
  # ------------------
  # 
  # Pass the field name as symbol and a message_id (will be translated) to :validate_fields:
  # 
  # Translating the validation messages:
  # ----------------------------------
  # 
  # Validationmessages will be send to I18n.t method with the scope "contactform.validations.#{field[1][:message].to_s}".
  # So a 'name' field with the validation message_id 'blank_name' will be available for translation in your locale files like:
  # 
  # de:
  #   contactform:
  #     validations:
  #       blank_name: 'Bitte geben Sie Ihren Namen an'
  # 
  # Example Contactform layout:
  # ---------------------------
  # 
  # :mailer:
  #   :form_layout_name: contact
  #   :fields:
  #     - subject: :string
  #     - name: :string
  #     - email: :string
  #     - message: :text
  #     - info: :boolean
  #   :validate_fields:
  #     :name:
  #       :message: blank_name
  #     :email:
  #       :message: blank_email
  
  include Tableless
  
  column :contact_form_id, :integer
  column :ip, :string
  Alchemy::Configuration.parameter(:mailer)[:fields].each do |field|
    column(field.keys.first.to_sym, field[field.keys.first.to_s].to_sym)
  end
  
  validate_fields = Alchemy::Configuration.parameter(:mailer)[:validate_fields]
  validate_fields.each do |field|
    validates_presence_of field[0], :message => I18n.t("contactform.validations.#{field[1][:message].to_s}")
    if field[0].to_s.include?('email')
      validates_format_of field[0], :with => Authlogic::Regex.email, :message => I18n.t('contactform.validations.wrong_email_format'), :if => :email_is_filled
    end
  end
  
private
  
  def email_is_filled 
    !email.blank? 
  end
  
end
