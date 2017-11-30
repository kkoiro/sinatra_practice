#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# version: ruby 2.4.1

require_relative './config/app_config'
require_relative './lib/connect_db'
require_relative './lib/models_loader'
require 'sinatra/base'
require 'sinatra/reloader'
require 'uri'
require 'rmagick'


class App < Sinatra::Base

  def get_user
    if session[:user_id].nil?
      @user = nil
    else
      @user = Attendee.find(session[:user_id])
    end
  end

  def set_message
    @message = session[:message]
    @alert_type = session[:alert_type]
  end

  def valid_user?(uid)
    session[:user_id] == uid.to_i
  end

  configure do
    AppConfig.get_config.each do |key, val|
      set key, val
    end
    register Sinatra::Reloader if Sinatra::Application.environment == :development
  end

  before do
    uri_path = URI.parse(request.url).path
    if ['/', '/login'].exclude?(uri_path) && session[:user_id].nil?
      unless uri_path =~ /^\/backdoor/
        session[:alert_type] = 'warning'
        session[:message] = 'Please log in to access other pages'
        redirect to('/')
      end
    end
    get_user()
  end

  after do
    if ['/', "/users/#{session[:user_id]}/profile", "/users/#{session[:user_id]}/password", "/users/#{session[:user_id]}/vote", "/backdoor/#{session[:login_secret]}"].include?(URI.parse(request.url).path)
      session[:message] = nil
      session[:alert_type] = nil
    end
  end

  get '/' do
    set_message()
    @css = ['/css/index.css']
    erb :index
  end

  post '/login' do
    user = Attendee.find_by(email: params['email'])
    if user && user.authenticate(params['password'])
      session[:user_id] = user.id
      session[:alert_type] = 'info'
      session[:message] = 'Successfully logged in'
    else
      session[:alert_type] = 'danger'
      session[:message] = 'Check your email and password'
    end
    @css = ['/css/index.css']
    redirect to('/')
  end

  post '/logout' do
    session.clear
    session[:alert_type] = 'danger'
    session[:message] = 'Logged out'
    redirect to('/')
  end

  get '/timetables/:date' do
    @css = ['/css/timetable.css']
    @sessions = Session.all
    @presentation_array = Array.new
    @sessions.each do |s|
      @presentation_array << s.presentations
    end

    case params['date'].to_i
    when 1
      erb :timetable_day1
    when 2
      erb :timetable_day2
    else
      404
    end
  end

  get '/presentations/:id' do
    @css = ['/css/presentation.css']
    @js = ['/js/presentation.js']
    @presentation_id = params[:id]
    begin
      @presentation = Presentation.find(params[:id])
      erb :presentation
    rescue => e
      404
    end
  end

  put '/presentations/:id/update_title' do
    begin
      presentation = Presentation.find(params[:id])
      if valid_user?(presentation.presenter_id)
        params[:title].strip!
        unless params[:title].empty?
          presentation.update(title: params[:title])
        end
      end
      redirect to("/presentations/#{params[:id]}")
    rescue => e
      403
    end
  end

  put '/presentations/:id/upload_slide' do
    begin
      presentation = Presentation.find(params[:id])
      if valid_user?(presentation.presenter_id)
        if params[:file]
          presentation.update(slide_title: params[:file][:filename], slide: true)
          path = "./public/files/#{params[:id]}_#{params[:file][:filename]}"
          File.open(path, 'wb') do |f|
            f.write(params[:file][:tempfile].read)
          end
        end
      end
      redirect to("/presentations/#{params[:id]}")
    rescue => e
      403
    end
  end

  delete '/presentations/:id/delete_slide' do
    begin
      presentation = Presentation.find(params[:id])
      if valid_user?(presentation.presenter_id)
        path = "./public/files/#{params[:id]}_#{presentation.slide_title}"
        File.delete(path) if File.exist?(path)
        presentation.update(slide_title: 'Not Uploaded', slide: false)
      end
      redirect to("/presentations/#{params[:id]}")
    rescue => e
      403
    end
  end

  get '/photos/:page' do
    @css = ['/css/photo.css']
    @js = ['/js/photo.js']
    display_photo_num = 30
    @page = params[:page].to_i
    @photo_num = Photo.count
    @page_num = 1
    unless @photo_num == 0
      @page_num = (@photo_num / display_photo_num.to_f).ceil
    end
    if 1 <= @page && @page <= @page_num
      sql_offset = display_photo_num * (@page - 1)
      @photos = Photo.limit(display_photo_num).offset(sql_offset)
      erb :photo
    else
      404
    end
  end

  post '/photos/:page/upload_photos' do
    record_num = Photo.count
    if params[:photos]
      params[:photos].each do |photo|
        record_num += 1
        path_original = "./public/photographs/original/#{record_num}_#{photo[:filename]}"
        path_thumbnail = "./public/photographs/thumbnail/#{record_num}_#{photo[:filename]}"
        thumbnail_height = 200.0
        image = Magick::Image.from_blob(photo[:tempfile].read).first
        image.write(path_original)
        image.sample(thumbnail_height/image.rows).write(path_thumbnail)
        Photo.create(file_name: "#{record_num}_#{photo[:filename]}")
      end
    end
    redirect to("/photos/#{params[:page]}")
  end

  get '/users/:id/profile' do
    set_message()
    @css = ['/css/user.css']
    @organizations = Organization.all
    @request_user_id = params[:id]
    begin
      if valid_user?(@request_user_id)
        @show_user = @user
      else
        @show_user = Attendee.find(@request_user_id)
      end
      erb :profile
    rescue => e
      404
    end
  end

  put '/users/:id/profile/update' do
    if valid_user?(params[:id])
      params[:email].strip!
      params[:name].strip!
      if Attendee.find(params[:id]).email == params[:email]
        email_duplication = false
      else
        email_duplication = Attendee.where(email: params[:email]).exist?
      end
      if params[:email].empty? || params[:name].empty? || params[:organization].empty?
        session[:alert_type] = 'danger'
        session[:message] = "Don't leave the form blank."
      elsif email_duplication
        session[:alert_type] = 'danger'
        session[:message] = "The email address requested is duplicate with another's one."
      else
        Attendee.find(params[:id]).update(email: params[:email], name: params[:name], organization_id: params[:organization])
        session[:alert_type] = 'success'
        session[:message] = 'Updated user profile successfully'
      end
      redirect to("/users/#{params[:id]}/profile")
    else
      403
    end
  end

  get '/users/:id/password' do
    if valid_user?(params[:id])
      set_message()
      @css = ['/css/user.css']
      erb :password
    else
      403
    end
  end

  put '/users/:id/password/update' do
    if valid_user?(params[:id])
      user = Attendee.find(session[:user_id])
      message_array = Array.new
      unless user.authenticate(params[:current_password])
        message_array << "Current password isn't valid"
      end
      unless params[:new_password] =~ /^[a-zA-Z0-9]{8,72}+$/
        message_array << "Only alphabets or numbers can be used"
      end
      password_length = params[:new_password].length
      unless 8 <= password_length && password_length <= 72
        message_array << "Password is too short or too long(must be 8-72 characters long)"
      end
      unless params[:new_password] == params[:password_confirmation]
        message_array << "Password doesn't match the confirmation"
      end
      if message_array.empty?
        session[:alert_type] = "success"
        session[:message] = "Updated password successfully"
        user.update(password: params[:new_password])
      else
        session[:alert_type] = "danger"
        session[:message] = message_array.join(', ')
      end
      redirect to("/users/#{params[:id]}/password")
    else
      403
    end
  end

  get '/users/:id/vote' do
    if valid_user?(params[:id])
      set_message()
      @presentations = Presentation.all
      @attendees = Attendee.all
      @presentation_vote_existance = PresentationVote.where(voter_id: params[:id]).any?
      @questioner_vote_existance = QuestionerVote.where(voter_id: params[:id]).any?
      @css = ['/css/user.css']
      erb :vote
    else
      403
    end
  end

  put '/users/:id/vote/best_presentation' do
    if valid_user?(params[:id])
      params[:presentation] ||= Array.new  # avoid nil
      if params[:presentation].length == 2
        PresentationVote.where(voter_id: params[:id]).delete_all
        params[:presentation].each do |presentation_id|
          PresentationVote.create(voter_id: params[:id], presentation_id: presentation_id)
        end
        session[:alert_type] = 'success'
        session[:message] = "Voted successfully"
      else
        session[:alert_type] = 'danger'
        session[:message] = "Choose just 2 presentation exactly"
      end
      redirect to("/users/#{params[:id]}/vote")
    else
      403
    end
  end

  put '/users/:id/vote/best_questioner' do
    if valid_user?(params[:id])
      params[:questioner] ||= Array.new  # avoid nil
      if params[:questioner].length == 2
        QuestionerVote.where(voter_id: params[:id]).delete_all
        params[:questioner].each do |questioner_id|
          QuestionerVote.create(voter_id: params[:id], questioner_id: questioner_id)
        end
        session[:alert_type] = 'success'
        session[:message] = "Voted successfully"
      else
        session[:alert_type] = 'danger'
        session[:message] = "Choose just 2 questioner exactly"
      end
      redirect to("/users/#{params[:id]}/vote")
    else
      403
    end
  end

  get '/backdoor/:secret' do
    @user = Attendee.where(login_secret: params[:secret]).take
    unless @user.nil?
      set_message()
      @css = ['/css/user.css']
      session[:login_secret] = params[:secret]
      erb :secret_password
    else
      404
    end
  end

  put '/backdoor/update_password' do
    login_secret = session[:login_secret]
    user = Attendee.where(login_secret: login_secret).take
    unless user.nil?
      message_array = Array.new
      unless params[:new_password] =~ /^[a-zA-Z0-9]{8,72}+$/
        message_array << "Only alphabets or numbers can be used"
      end
      password_length = params[:new_password].length
      unless 8 <= password_length && password_length <= 72
        message_array << "Password is too short or too long(must be 8-72 characters long)"
      end
      unless params[:new_password] == params[:password_confirmation]
        message_array << "Password doesn't match the confirmation"
      end
      if message_array.empty?
        user.update(password: params[:new_password])
        session[:alert_type] = 'success'
        session[:message] = "Password has been updated, so plase log in with new password."
        redirect to('/')
      else
        session.clear
        session[:alert_type] = "danger"
        session[:message] = message_array.join(', ')
        redirect to("/backdoor/#{login_secret}")
      end
    else
      403
    end
  end

end
