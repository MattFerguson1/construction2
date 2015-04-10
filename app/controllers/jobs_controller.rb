require 'cb'
require 'nokogiri'

class JobsController < ApplicationController
  def search
    job_client = Cb.job
    results = job_client.search({ location: 'Atlanta, GA', ONetCode: '47-0000' })
    job_dids = results.model.jobs.map { |job_model| job_model.did }
    @jobs = job_dids.map { |did| job_client.find_by_did(did) }

    @jobs.each do |job|
      doc = Nokogiri::XML::fragment(job.model.description)
      job.model.description = doc.text.html_safe
    end
  end
end