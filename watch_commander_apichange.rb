#######################################################################################
#
# File       : watch_commander.rb
# Class      : WatchCommander
#
# Purpose    : Connect directly to firmware API of a smartwatch through Fleet Manager
# Written by : james@ekta.co
# Last update: May 2022
#
#######################################################################################

# for gemming
require 'rubygems'

# for http calls and parsing
require 'net/http'
require 'uri'
require 'faraday'
require 'json'

class WatchCommander

  PROD_API_URI   = "https://mgr.pingcares.com/SendCommand/SendForAPI"
  PROD_LOGIN_URI = "https://mgr.pingcares.com/Login/SignIn"

  # DEPRECATED 6/19/22
  COOKIE = ''

  CMD_STEPKUDOS        = 'IWBP43'
  CMD_MESSAGE          = 'IWBP40'
  CMD_KUDOS            = 'IWBP71'
  CMD_SETSOS           = 'IWBP12'
  CMD_WHITELIST_ENABLE = 'IWBP84'
  CMD_MOOD             = 'IWBPMP'
  #CMD_MOOD             = 'IWBPMP'

  @imei = nil

  attr_accessor :imei


  def initialize(imei=nil)
    if imei
      @imei = imei
    end

    @cookie = ''
  end



  def login(username=nil, password=nil)
    begin
      data = {
        :TxtUserName => username,
        :TxtUserPassword => password,
        :loginLan => 'en-us',
        :hidRememberPwd => '1',
        :txtTimeOffset => '-6',
        :IsNew => '1'
      }

      response = Faraday.post(PROD_LOGIN_URI) do |req|
        req.headers['Accept'] = '*/*'
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.headers['charset'] = 'UTF-8'
        req.headers['X-Requested-With'] = 'XmlHttpRequest'
        req.headers['Origin'] = 'https://mgr.pingcares.com'
        req.headers['DNT'] = '1'
        req.headers['Referer'] = 'https://mgr.pingcares.com/en-us'
        req.headers['Sec-Fetch-Dest'] = 'empty'
        req.headers['Sec-Fetch-Mode'] = 'cors'
        req.headers['Sec-Fetch-Site'] = 'same-origin'
        req.headers['Pragma'] = 'no-cache'
        req.headers['Cache-Control'] = 'no-cache'
        req.headers['TE'] = 'trailers'

        req.body = URI.encode_www_form(data)
      end
      puts response.inspect
      cookie_d = response.headers['set-cookie'].to_s
      cookie_d = cookie_d.split(/; /, 2)
      @cookie = cookie_d[0]
      puts @cookie
    rescue => e
      puts e.inspect
    end
  end # end login method


  def sendCommand (command)
    data = {
      :P => @imei,
      :CmdCode => command
      :Params =>
    }


    begin
      response = Faraday.post(PROD_API_URI) do |req|
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.headers['Cookie'] = @cookie
        req.body = URI.encode_www_form(data)
      end

      result = JSON.parse(response.body)
    rescue => e
      puts e.inspect
    end
  end # end sendcommand method

  def sendFlower
  end



  def sendStepKudos(steps)
    command = CMD_STEPKUDOS + ',' + @imei + ',080835,' + steps.to_s + '#'
    #puts command
    return self.sendCommand(command)
  end

  # deprecated
  def oldSendKudos(name)
    command = CMD_KUDOS + ',' + @imei + ',' + name + ",080835#"
    #puts command
    return self.sendCommand(command)
  end

  def sendKudos(name)
    return self.sendReminder(name)
  end

  def enableWhiteList
    command = CMD_WHITELIST_ENABLE + ',' + @imei + ',080835,1'
    #puts command
    return self.sendCommand(command)
  end

  def sendReminder(reminder_text)
    command = CMD_MESSAGE + ',' + @imei + ',080835,' + reminder_text.to_s + '#'
    #puts command
    return self.sendCommand(command)
  end

  def updateSOS

  end

  def sendMoodReminder()
    command = CMD_MOOD + ',' + @imei + ',080835,mood#'
    puts command
    return self.sendCommand(command)
  end

  def sendPainReminder()
    command = CMD_MOOD + ',' + @imei + ',080835,pain#'
    puts command
    return self.sendCommand(command)
  end

end