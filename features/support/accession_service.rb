#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2015 Genome Research Ltd.

require File.expand_path(File.join(File.dirname(__FILE__), 'fake_sinatra_service.rb'))

class FakeAccessionService < FakeSinatraService
  def initialize(*args, &block)
    super
    configatron.accession_url      = "http://#{host}:#{port}/accession_service/"
    configatron.accession_view_url = "http://#{host}:#{port}/view_accession/"
  end

  def bodies
    @bodies ||= []
  end

  def sent
    @sent ||= []
  end

  def last_received
    @last_received
  end

  def clear
    @bodies = []
  end

  def success(type, accession, body = "")
    model = type.upcase
    self.bodies << <<-XML
      <RECEIPT success="true">
        <#{model} accession="#{accession}">#{body}</#{model}>
        <SUBMISSION accession="EGA00001000240" />
      </RECEIPT>
    XML
  end

  def failure(message)
    self.bodies << %Q{<RECEIPT success="false"><ERROR>#{ message }</ERROR></RECEIPT>}
  end

  def next!
    @last_received = self.bodies.pop
  end

  def service
    Service
  end

  def add_payload(payload)
    sent.push(Hash[*payload.map{|k,v| [k, v.readlines]}.map{|k,v| [k,(v unless v.empty?)]}.flatten])
  end

  class Service < FakeSinatraService::Base
    post('/accession_service/era_accession_login') do
      response = FakeAccessionService.instance.next! or halt(500)
      headers('Content-Type' => 'text/xml')
      body(response)
    end

    post('/accession_service/ega_accession_login') do
      response = FakeAccessionService.instance.next! or halt(500)
      headers('Content-Type' => 'text/xml')
      body(response)
    end
  end
end

RestClient::Resource.class_eval do |klass|
  alias_method :original_post, :post
  def post(payload)
    FakeAccessionService.instance.add_payload(payload)
    original_post(payload)
  end
end


FakeAccessionService.install_hooks(self, '@accession-service')
