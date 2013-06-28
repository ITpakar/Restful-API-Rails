class PushNotification
  attr_accessor :device_token, :alert, :certificate, :passphrase, :gateway

  def initialize(device_token, alert)
    @device_token = device_token
    @alert = alert
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

  def self.pusher
    Grocer.pusher(
      certificate: certificate,
      passphrase:  passphrase,
      gateway:     gateway,
      port:        2195,
      retries:     3
    )
  end

  def notification
    Grocer::Notification.new(
      device_token:      device_token,
      alert:             alert,
      sound:             "siren.aiff",
      badge:             1
    )
  end

  def push
    PushNotification.pusher.push(notification)
  end
end