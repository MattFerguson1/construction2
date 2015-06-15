require 'cb'
require 'nokogiri'

class JobsController < ApplicationController
  def search
    #we are taking the value of the keyword input from the form and assigning to this variable
    #params will contain any values from a form that was submitted

    # This is creating a new instance of the Job Client from the API wrapping gem that is used to talk to the API
    job_client = Cb.job

    #storing the results from a call to job_client.search]
    #the search method takes in a hash of parameters that we pass into the api call
    results = job_client.search({ location: user_location, ONetCode: '47-0000', Keywords: user_keyword })

    # take all the jobs off of the results that came back and grab thier dids
    job_dids = results.model.jobs.map { |job_model| job_model.did }

    # for each job did that came back call the api to get the job details
    #because this variable has the @ sign that means its an instace variable & its availible to the view
    @jobs = job_dids.map { |did| job_client.find_by_did(did) }

    #For each job object take the description and format it for html display
    @jobs.each do |job|
      doc = Nokogiri::XML::fragment(job.model.description)
      job.model.description = doc.text.html_safe
    end
  end

  def details
    job_client = Cb.job
    @job = job_client.find_by_did job_did
    doc = Nokogiri::XML::fragment(@job.model.description)
    @job.model.description = doc.text.html_safe
  end

  private

  def user_keyword
    params[:keyword]
  end

  def user_location
    params[:location]
  end

  def job_did
    params[:job_did]
  end

end