class PushNotification
  attr_accessor :device_token, :alert, :certificate, :passphrase, :gateway, :identifier, :badge, :custom, :feedback

  def initialize(device_token, alert, raw_options = {})
    raw_options.symbolize_keys!
    options = { identifier: 0, badge: 0, custom: {} }.deep_merge(raw_options)
    
    @device_token = device_token
    @alert = alert
    @identifier = options[:identifier]
    @badge = options[:badge]
    @custom = options[:custom]
  end

  def self.certificate
    File.join(Rails.root, 'certs', 'development.pem')
  end

  def self.passphrase
    'quotiful123'
  end

  def self.gateway
    'gateway.sandbox.push.apple.com'
  end

  def self.feedback
    'feedback.sandbox.push.apple.com'
  end

  def self.pusher
    Grocer.pusher(
      certificate: certificate,
      passphrase:  passphrase,
      gateway:     gateway,
      port:        2195,
      retries:     3
    )
  end

  def self.feedbacker
    feedback = Grocer.feedback(
      certificate: certificate,
      passphrase:  passphrase,
      gateway:     feedback,
      port:        2196,
      retries:     3
    )

    feedback.each do |attempt|
      Device.where(device_token: attempt.device_token).destroy_all
    end
  end

  def notification
    Grocer::Notification.new(
      device_token:      device_token,
      alert:             alert,
      sound:             "siren.aiff",
      badge:             badge,
      identifier:        identifier,
      custom:            custom
    )
  end

  def print_log
    file = File.open(File.join(Rails.root.to_s, "log/apn.log"), "a")
    file.puts(self.inspect)
    file.close
  end

  def push
    print_log
    PushNotification.pusher.push(notification)
    PushNotification.feedbacker
  end
end