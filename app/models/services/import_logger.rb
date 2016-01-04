class ImportLogger
  def self.logger
    @@logger ||= Logger.new("#{Rails.root}/log/import_error.log")
  end

  def self.error(brn, error)
    error_message = I18n.t("activerecord.errors.models.book.#{error}")
    self.logger.error("#{brn}: #{error_message}")
  end
end