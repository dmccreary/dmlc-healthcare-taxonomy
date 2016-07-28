require 'pp'
require 'tempfile'
require 'date'
#
# Put your custom functions in this class in order to keep the files under lib untainted
#
# This class has access to all of the private variables in deploy/lib/server_config.rb
#
# any public method you create here can be called from the command line. See
# the examples below for more information.
#
class ServerConfig

  #
  # You can easily "override" existing methods with your own implementations.
  # In ruby this is called monkey patching
  #
  # first you would rename the original method
  # alias_method :original_deploy_modules, :deploy_modules

  # then you would define your new method
  # def deploy_modules
  #   # do your stuff here
  #   # ...

  #   # you can optionally call the original
  #   original_deploy_modules
  # end

  #
  # you can define your own methods and call them from the command line
  # just like other roxy commands
  # ml local my_custom_method
  #
  # def my_custom_method()
  #   # since we are monkey patching we have access to the private methods
  #   # in ServerConfig
  #   @logger.info(@properties["ml.content-db"])
  # end

  #
  # to create a method that doesn't require an environment (local, prod, etc)
  # you woudl define a class method
  # ml my_static_method
  #
  # def self.my_static_method()
  #   # This method is static and thus cannot access private variables
  #   # but it can be called without an environment
  # end

  def dep
    deploy_src
  end

  def deploy_users
    log_header "Deploying Users"
    ARGV.push('import')
    ARGV.push('-input_file_path')
    ARGV.push('data/users')
    ARGV.push('-document_type')
    ARGV.push('text')
    ARGV.push('-output_uri_replace')
    ARGV.push(%Q{"#{ServerConfig.expand_path("#{@@path}/../data")},''"})
    ARGV.push('-transform_module')
    ARGV.push('/transform/from-json.xqy')
    ARGV.push('-transform_namespace')
    ARGV.push('"http://marklogic.com/transform/from-json"')
    ARGV.push('-transform_function')
    ARGV.push('transform')
    ARGV.push('-output_collections')
    ARGV.push('user')
    ARGV.push('-output_permissions')

    role_name = @properties['ml.app-name'] + "-role"
    ARGV.push("#{role_name},read,#{role_name},update,#{role_name},insert,#{role_name},execute")
    mlcp
  end

  def deploy_codes
    log_header "Deploying Codes"

    ARGV.push('import')
    ARGV.push('-input_file_path')
    ARGV.push('data/codes')
    ARGV.push('-output_uri_replace')
    ARGV.push(%Q{"#{ServerConfig.expand_path("#{@@path}/../data")},''"})
    ARGV.push('-output_collections')
    ARGV.push('codes')
    ARGV.push('-output_permissions')

    role_name = @properties['ml.app-name'] + "-role"
    ARGV.push("#{role_name},read,#{role_name},update,#{role_name},insert,#{role_name},execute")
    mlcp

    execute_query(%Q{
      let $json := xdmp:from-json-string(fn:doc('/codes/new-ndc-codes.txt'))
      for $key in map:keys($json)
      return
       xdmp:document-insert("/ndc-codes/new/" || $key || ".xml", <code key="{$key}">{map:get($json, $key)}</code>, xdmp:default-permissions(), "new-ndc-codes")
    },
    :app_name => @properties['ml.app-name'])

    execute_query(%Q{
      let $json := xdmp:from-json-string(fn:doc('/codes/old-ndc-codes.txt'))
      for $key in map:keys($json)
      return
       xdmp:document-insert("/ndc-codes/old/" || $key || ".xml", <code key="{$key}">{map:get($json, $key)}</code>, xdmp:default-permissions(), "old-ndc-codes")
    },
    :app_name => @properties['ml.app-name'])

  end

  def deploy_patient_records
    ARGV.push('import')
    ARGV.push('-input_file_path')
    ARGV.push('data/C32_EHRs')
    ARGV.push('-document_type')
    ARGV.push('xml')
    ARGV.push('-output_uri_replace')
    ARGV.push(%Q{"#{ServerConfig.expand_path("#{@@path}/../data/C32_EHRs")},'/patients'"})
    ARGV.push('-output_collections')
    ARGV.push('patient')
    ARGV.push('-output_permissions')

    role_name = @properties['ml.app-name'] + "-role"
    ARGV.push("#{role_name},read,#{role_name},update,#{role_name},insert,#{role_name},execute")
    mlcp
  end

  def download_npi_data
    log_header "Downloading NPI Provider data"
    filename = "NPPES_Data_Dissemination_#{Date::MONTHNAMES[Date.today.month]}_#{Date.today.year}.zip"
    `curl -o data/npi/#{filename} http://nppes.viva-it.com/#{filename}` unless File.exist?("data/npi/#{filename}")

    unless Dir.glob("data/npi/npidata*.csv").count > 0
      log_header "Extracting NPI Archive"
      seven_zip = `which 7za`.gsub(/[\r\n]/, "")
      if seven_zip != ""
        file_to_extract = `#{seven_zip} l data/npi/#{filename} | grep '\\d\\.csv' | awk '{print $6}'`.gsub(/[\r\n]/,"")
        logger.info "file: #{file_to_extract}"
        split_path = '/usr/local/bin/gsplit'
        cmd = %Q{#{seven_zip} e -odata/npi/ data/npi/#{filename} #{file_to_extract}}
        logger.info cmd
        logger.info `#{cmd}`

        log_header "Splitting csv file"
        logger.info `pushd data/npi; tail -n +2 #{file_to_extract} | #{split_path} --bytes=500MB -d --filter='sh -c "{ head -n 1 #{file_to_extract}; cat; } > $FILE"' --additional-suffix=.csv - npi-split-; popd`
      else
        raise ExitException.new("You need 7zip installed to extract the NPI file: http://www.7-zip.org/download.html")
      end
    end
  end

  def deploy_npi
    download_npi_data unless small

    log_header "Deploying Providers   small: #{small}"


    ARGV.push('import')
    ARGV.push('-input_file_path')
    unless small
      ARGV.push('data/npi')
      ARGV.push('-input_file_pattern')
      ARGV.push(%Q{'npi-split.*\.csv'})
    else
      ARGV.push('data/npi-small')
    end
    ARGV.push('-input_file_type')
    ARGV.push('delimited_text')
    ARGV.push('-delimited_root_name')
    ARGV.push('provider')
    ARGV.push('-output_uri_prefix')
    ARGV.push('/providers/')
    ARGV.push('-output_uri_suffix')
    ARGV.push('.xml')
    ARGV.push('-output_collections')
    ARGV.push('provider')
    ARGV.push('-transform_module')
    ARGV.push('/transform/npi.xqy')
    ARGV.push('-transform_namespace')
    ARGV.push('"http://marklogic.com/transform/npi"')
    ARGV.push('-transform_function')
    ARGV.push('transform')
    ARGV.push('-output_permissions')

    role_name = @properties['ml.app-name'] + "-role"
    ARGV.push("#{role_name},read,#{role_name},update,#{role_name},insert,#{role_name},execute")
    mlcp

    # now add the cpt codes into the freshly loaded providers
    add_cpt_to_providers
  end

  def download_prescriber_charge_data
    filename = "PartD_Prescriber_PUF_NPI_DRUG_13.zip"
    data_dir = ServerConfig.expand_path("#{@@path}/../data/prescriber-charge-data")
    data_file = File.join(data_dir, filename)
    FileUtils.mkdir_p data_dir unless File.exist?(data_dir)

    unless File.exist?(data_file)
      log_header "Downloading Prescriber Charge data"
      `curl -o "#{data_file}" http://download.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Medicare-Provider-Charge-Data/Downloads/#{filename}`
    end

    unless File.exist?("#{data_dir}/PartD_Prescriber_PUF_NPI_DRUG_13.txt")
      log_header "Extracting Prescriber charge data Archive"
      `unzip #{data_file} -d #{data_dir}`
    end
  end

  def deploy_prescriber_charge
    download_prescriber_charge_data unless small

    log_header "Deploying Providers   small: #{small}"

    opts = ::Tempfile.new('opts')
    begin
      opts.write(%Q{-input_file_type\ndelimited_text\n-delimiter\n"\t"})
      opts.rewind

      ARGV.push('import')
      ARGV.push('-input_file_path')
      ARGV.push('data/prescriber-charge-data/PartD_Prescriber_PUF_NPI_DRUG_13.txt')
      ARGV.push('-options_file')
      ARGV.push(%Q{"#{opts.path}"})
      ARGV.push('-delimited_root_name')
      ARGV.push('prescriber-charge-data')
      ARGV.push('-output_uri_prefix')
      ARGV.push('/prescriber-charge-data/')
      ARGV.push('-output_uri_suffix')
      ARGV.push('.xml')

      ARGV.push('-output_collections')
      ARGV.push('"Medicare D"')
      # ARGV.push('-transform_module')
      # ARGV.push('/transform/npi.xqy')
      # ARGV.push('-transform_namespace')
      # ARGV.push('"http://marklogic.com/transform/npi"')
      # ARGV.push('-transform_function')
      # ARGV.push('transform')
      ARGV.push('-output_permissions')

      role_name = @properties['ml.app-name'] + "-role"
      ARGV.push("#{role_name},read,#{role_name},update,#{role_name},insert,#{role_name},execute")
      mlcp
    ensure
      opts.close
      opts.unlink
    end
  end

  def deploy_provider_charge_data
    return if small

    log_header "Deploying Provider Charge Data   small: #{small}"

    data_dir = ServerConfig.expand_path("#{@@path}/../data/provider-charge-data")
    data_file = ServerConfig.expand_path("#{@@path}/../data/provider-charge-data/pcd.zip")
    unless File.exist?(data_file)
      logger.info "Downloading the mappings for your..."
      FileUtils.mkdir_p(data_dir) unless Dir.exists?(data_dir)
      `curl -o #{data_file} http://download.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Medicare-Provider-Charge-Data/Downloads/Medicare-Physician-and-Other-Supplier-PUF-CY2012.zip?agree=yes&next=Accept`
    end

    final_file = ServerConfig.expand_path("#{@@path}/../data/provider-charge-data/Medicare-Physician-and-Other-Supplier-PUF-CY2012.txt")
    unless File.exist?(final_file)
      logger.info "Unzipping data file..."
      `unzip #{data_file} -d #{data_dir}`
    end

    opts = ::Tempfile.new('opts')
    begin
      opts.write(%Q{-input_file_type\ndelimited_text\n-delimiter\n"\t"})
      opts.rewind

      ARGV.push('import')
      ARGV.push('-input_file_path')
      ARGV.push('data/provider-charge-data/Medicare-Physician-and-Other-Supplier-PUF-CY2012.txt')
      ARGV.push('-options_file')
      ARGV.push(%Q{"#{opts.path}"})
      ARGV.push('-split_input')
      ARGV.push('true')
      ARGV.push('-max_split_size')
      ARGV.push('10240')
      ARGV.push('-delimited_root_name')
      ARGV.push('provider-charge-data')
      ARGV.push('-generate_uri')
      ARGV.push('true')
      ARGV.push('-output_uri_prefix')
      ARGV.push('/provider-charge-data/')
      ARGV.push('-output_uri_suffix')
      ARGV.push('.xml')
      ARGV.push('-output_collections')
      ARGV.push('provider-charge-data')
      ARGV.push('-output_permissions')

      role_name = @properties['ml.app-name'] + "-role"
      ARGV.push("#{role_name},read,#{role_name},update,#{role_name},insert,#{role_name},execute")
      mlcp
    ensure
      opts.close
      opts.unlink
    end

  end

  def add_cpt_to_providers
    ARGV.push('--uris=/corb/add-cpt-to-providers/get-uris.xqy')
    ARGV.push('--modules=/corb/add-cpt-to-providers/go.xqy')
    ARGV.push('--threads=8')
    corb
  end

  def enrich_patients
    ARGV.push('--uris=/corb/enrich-patients/get-uris.xqy')
    ARGV.push('--modules=/corb/enrich-patients/go.xqy')
    ARGV.push('--threads=8')
    corb
  end

  def enrich_faers
    ARGV.push('--uris=/corb/enrich-faers/get-uris.xqy')
    ARGV.push('--modules=/corb/enrich-faers/go.xqy')
    ARGV.push('--threads=8')
    corb
  end

  def enrich_spl
    ARGV.push('--uris=/corb/enrich-spl/get-uris.xqy')
    ARGV.push('--modules=/corb/enrich-spl/go.xqy')
    ARGV.push('--threads=8')
    corb
  end

  def enrich_tweets
    ARGV.push('--uris=/corb/enrich-tweets/get-uris.xqy')
    ARGV.push('--modules=/corb/enrich-tweets/go.xqy')
    ARGV.push('--threads=8')
    corb
  end

  def deploy_summary_claims
    log_header "Deploying Patient Records"

    ARGV.push('import')
    ARGV.push('-input_file_path')
    ARGV.push("data/#{claims_dir}/summary")
    ARGV.push('-input_compressed') unless small
    ARGV.push('-input_file_type')
    ARGV.push('delimited_text')
    ARGV.push('-delimited_root_name')
    ARGV.push("patient-summary")
    ARGV.push('-output_uri_prefix')
    ARGV.push("/patients/")
    ARGV.push('-output_uri_suffix')
    ARGV.push('.xml')
    ARGV.push('-output_collections')
    ARGV.push("patient")
    ARGV.push('-transform_module')
    ARGV.push('/transform/patient-transform.xqy')
    ARGV.push('-transform_namespace')
    ARGV.push('"http://marklogic.com/transform/patient"')
    ARGV.push('-transform_function')
    ARGV.push('transform')
    ARGV.push('-output_permissions')

    role_name = @properties['ml.app-name'] + "-role"
    ARGV.push("#{role_name},read,#{role_name},update,#{role_name},insert,#{role_name},execute")
    mlcp
  end

  def deploy_outpatient_claims
    log_header "Deploying Outpatient Claims   small: #{small}"

    ARGV.push('import')
    ARGV.push('-input_file_path')
    ARGV.push("data/#{claims_dir}/outpatient")
    ARGV.push('-input_compressed') unless small
    ARGV.push('-input_file_type')
    ARGV.push('delimited_text')
    ARGV.push('-delimited_root_name')
    ARGV.push("outpatient-claim")
    ARGV.push('-output_uri_prefix')
    ARGV.push("/claims/outpatient/")
    ARGV.push('-output_uri_suffix')
    ARGV.push('.xml')
    ARGV.push('-output_collections')
    ARGV.push("claim")
    ARGV.push('-transform_module')
    ARGV.push('/transform/patient-transform.xqy')
    ARGV.push('-transform_namespace')
    ARGV.push('"http://marklogic.com/transform/patient"')
    ARGV.push('-transform_function')
    ARGV.push('transform')
    ARGV.push('-output_permissions')

    role_name = @properties['ml.app-name'] + "-role"
    ARGV.push("#{role_name},read,#{role_name},update,#{role_name},insert,#{role_name},execute")
    mlcp
  end

  def deploy_inpatient_claims
    log_header "Deploying Inpatient Claims   small: #{small}"

    ARGV.push('import')
    ARGV.push('-input_file_path')
    ARGV.push("data/#{claims_dir}/inpatient")
    ARGV.push('-input_compressed') unless small
    ARGV.push('-input_file_type')
    ARGV.push('delimited_text')
    ARGV.push('-delimited_root_name')
    ARGV.push("inpatient-claim")
    ARGV.push('-output_uri_prefix')
    ARGV.push("/claims/inpatient/")
    ARGV.push('-output_uri_suffix')
    ARGV.push('.xml')
    ARGV.push('-output_collections')
    ARGV.push("claim")
    ARGV.push('-transform_module')
    ARGV.push('/transform/patient-transform.xqy')
    ARGV.push('-transform_namespace')
    ARGV.push('"http://marklogic.com/transform/patient"')
    ARGV.push('-transform_function')
    ARGV.push('transform')
    ARGV.push('-output_permissions')

    role_name = @properties['ml.app-name'] + "-role"
    ARGV.push("#{role_name},read,#{role_name},update,#{role_name},insert,#{role_name},execute")
    mlcp
  end

  def deploy_rx_claims
    log_header "Deploying Rx Claims   small: #{small}"

    ARGV.push('import')
    ARGV.push('-input_file_path')
    ARGV.push("data/#{claims_dir}/rx")
    ARGV.push('-input_compressed') unless small
    ARGV.push('-input_file_type')
    ARGV.push('delimited_text')
    ARGV.push('-delimited_root_name')
    ARGV.push("rx-claim")
    ARGV.push('-delimited_uri_id')
    ARGV.push("PDE_ID")
    ARGV.push('-output_uri_prefix')
    ARGV.push("/claims/rx/")
    ARGV.push('-output_uri_suffix')
    ARGV.push('.xml')
    ARGV.push('-output_collections')
    ARGV.push("claim")
    ARGV.push('-transform_module')
    ARGV.push('/transform/patient-transform.xqy')
    ARGV.push('-transform_namespace')
    ARGV.push('"http://marklogic.com/transform/patient"')
    ARGV.push('-transform_function')
    ARGV.push('transform')
    ARGV.push('-output_permissions')

    role_name = @properties['ml.app-name'] + "-role"
    ARGV.push("#{role_name},read,#{role_name},update,#{role_name},insert,#{role_name},execute")
    mlcp
  end

  def get_claims_files
    log_header "Downloading CMS Anonymized Claims data"
    url_prefix = "http://www.cms.gov/Research-Statistics-Data-and-Systems/Downloadable-Public-Use-Files/SynPUFs/Downloads/"
    drug_url_prefix = "http://downloads.cms.gov/files/"

    (1..20).each do |index|

      #summary files
      [
        "DE1_0_2008_Beneficiary_Summary_File_Sample_#{index}.zip",
        "DE1_0_2009_Beneficiary_Summary_File_Sample_#{index}.zip",
        "DE1_0_2010_Beneficiary_Summary_File_Sample_#{index}.zip"
      ].each do |file|
        `curl -o data/claims/summary/#{file} #{url_prefix}#{file}` unless File.exist?("data/claims/summary/#{file}")
      end

      #inpatient
      file = "DE1_0_2008_to_2010_Inpatient_Claims_Sample_#{index}.zip"
      `curl -o data/claims/inpatient/#{file} #{url_prefix}#{file}` unless File.exist?("data/claims/inpatient/#{file}")

      #outpatient
      file = "DE1_0_2008_to_2010_Outpatient_Claims_Sample_#{index}.zip"
      `curl -o data/claims/outpatient/#{file} #{url_prefix}#{file}` unless File.exist?("data/claims/outpatient/#{file}")

      #rx
      file = "DE1_0_2008_to_2010_Prescription_Drug_Events_Sample_#{index}.zip"
      `curl -o data/claims/rx/#{file} #{drug_url_prefix}#{file}` unless File.exist?("data/claims/rx/#{file}")
    end
  end

  def deploy_claims
    get_claims_files unless small
    deploy_inpatient_claims
    deploy_outpatient_claims
    deploy_rx_claims
    deploy_summary_claims
  end

  def self.split_csv_line(line)
    row = []
    need_quote = false
    line.scan(/"(.*?)"[\r\n,]|(.*?)[\r\n,]/).each do |a|
      item = nil
      item = a[0] if a[0]
      item = a[1] if a[1]
      item = "" unless item
      if (need_quote == true) then
        temp = row[row.length - 1] + "," + item
        row[row.length - 1] = temp.strip.chomp('"').reverse.chomp('"').reverse
        need_quote = false
      else
        if (item.scan(/"/).length % 2 != 0) then
          need_quote = true
          row << item
        else
          row << item.strip
        end
      end
    end
    row
  end

  def self.build_codes
    build_icd9
    build_npi_taxonomy_lookup
    build_ndc_lookups
  end

  def self.build_icd9
    %w(diagnosis procedure).each do |type|
      Dir.glob("data/icd9/#{type}/*.txt") do |file|
        list = {}
        File.readlines(file)[1..-1].each do |line|
          code, desc = $1, $2 if line.encode('UTF-8', :invalid => :replace) =~ /^(\w+)\s+(.+)$/
          list[code] = desc
        end
        File.open("data/codes/icd9-#{type.downcase}-codes.txt", "w") { |file| file.write(JSON.generate(list)) }
      end
    end
  end

  def self.build_npi_taxonomy_lookup
    # dir = ServerConfig.expand_path("#{@@path}/../data/codes/npi")
    Dir.glob('data/npi-taxonomy-list/*.csv') do |file|
      list = {}
      File.readlines(file)[1..-1].each do |line|
        splits = split_csv_line(line.encode('UTF-8', :invalid => :replace))#line.encode('UTF-8', :invalid => :replace).split(",")
        list[splits[0]] ={
          "code" => splits[0],
          "type" => splits[1],
          "classification" => splits[2],
          "specialization" => splits[3],
          "definition" => splits[4]
        }
      end
      logger.info JSON.generate(list)
    end
  end

  def self.build_ndc_lookups
    Dir.glob('data/ndc/listings.TXT') do |file|
      list = {}
      File.readlines(file).each do |line|
        ndc = line[9..18].strip.gsub(' ', '')
        dose_num = line[20..30].strip
        dose_txt = line[31..41].strip
        drug_name = line[42..-1].strip

        list[ndc] = [drug_name, dose_num, dose_txt].join(' ')
      end
      File.open("data/codes/old-ndc-codes.txt", "w") { |file| file.write(JSON.generate(list)) }
    end


    Dir.glob('data/ndc/product.txt') do |file|
      list = {}
      File.readlines(file).each do |line|
        splits = line.split("\t")
        ndc = splits[1].gsub('-', '')
        dose_num = splits[14]
        dose_txt = splits[15]
        drug_name = splits[3]

        list[ndc] = [drug_name, dose_num, dose_txt].join(' ')
      end
      File.open("data/codes/new-ndc-codes.txt", "w") { |file| file.write(JSON.generate(list)) }
    end
  end

  def get_spl
    (1..3).each do |index|
      filename = "dm_spl_release_human_rx_part#{index}.zip"
      `curl -o data/spl/#{filename} ftp://public.nlm.nih.gov/nlmdata/.dailymed/#{filename}` unless File.exist?("data/spl/#{filename}")
    end
  end

  def deploy_spl
    log_header "Deploying Structured Product Labels"

    ARGV.push('import')
    ARGV.push('-input_file_path')
    ARGV.push('data/spl')
    ARGV.push('-input_compressed')
    ARGV.push('-output_uri_replace')
    ARGV.push(%Q{"#{ServerConfig.expand_path("#{@@path}/../data")},''"})
    # ARGV.push('-transform_module')
    # ARGV.push('/lib/spl-transform.xqy')
    # ARGV.push('-transform_namespace')
    # ARGV.push('"http://marklogic.com/ns/spl-transform"')
    # ARGV.push('-output_collections')
    # ARGV.push('spl')

    ARGV.push('-output_permissions')

    role_name = @properties['ml.app-name'] + "-role"
    ARGV.push("#{role_name},read,#{role_name},update,#{role_name},insert,#{role_name},execute")
    mlcp

    execute_query(%Q{
      cts:uri-match("/spl/*.xml") ! xdmp:document-set-collections(., "spl")
    },
    :app_name => @properties['ml.app-name'])

    # http://dailymed.nlm.nih.gov/dailymed/downloadLabels.cfm - grab the human rx. It's usually a couple of huge zip files.
  end

  def deploy_atc
    log_header "Deploying ATC triples"
    ARGV.push('import')
    ARGV.push('-input_file_path')
    ARGV.push('data/triples/ATC.ttl.zip')
    ARGV.push('-input_file_type')
    ARGV.push('RDF')
    ARGV.push('-input_compressed')
    ARGV.push('-output_uri_prefix')
    ARGV.push('/atc/')
    ARGV.push('-output_collections')
    ARGV.push('atc')
    mlcp
  end

  def deploy_rxnorm
    log_header "Deploying RXNorm triples"

    ARGV.push('import')
    ARGV.push('-input_file_path')
    ARGV.push('data/triples/RXNORM.ttl.zip')
    ARGV.push('-input_file_type')
    ARGV.push('RDF')
    ARGV.push('-input_compressed')
    ARGV.push('-output_uri_prefix')
    ARGV.push('/rxnorm/')
    ARGV.push('-output_collections')
    ARGV.push('rxnorm')
    mlcp
  end

  def deploy_nddf
    log_header "Deploying NDDF triples"

    ARGV.push('import')
    ARGV.push('-input_file_path')
    ARGV.push('data/triples/NDDF.ttl.zip')
    ARGV.push('-input_file_type')
    ARGV.push('RDF')
    ARGV.push('-input_compressed')
    ARGV.push('-output_uri_prefix')
    ARGV.push('/nddf/')
    ARGV.push('-output_collections')
    ARGV.push('nddf')
    mlcp
  end

  def deploy_icd9_trips
    log_header "Deploying ICD9 triples"

    ARGV.push('import')
    ARGV.push('-input_file_path')
    ARGV.push('data/triples/ICD9CM.ttl.zip')
    ARGV.push('-input_file_type')
    ARGV.push('RDF')
    ARGV.push('-input_compressed')
    ARGV.push('-output_uri_prefix')
    ARGV.push('/icd9-triples/')
    ARGV.push('-output_collections')
    ARGV.push('icd9-triples')
    mlcp
  end

  def deploy_cpt_trips
    log_header "Deploying CPT triples"

    ARGV.push('import')
    ARGV.push('-input_file_path')
    ARGV.push('data/triples/CPT.ttl.zip')
    ARGV.push('-input_file_type')
    ARGV.push('RDF')
    ARGV.push('-input_compressed')
    ARGV.push('-output_uri_prefix')
    ARGV.push('/cpt-triples/')
    ARGV.push('-output_collections')
    ARGV.push('cpt-triples')
    mlcp
  end
  # http://www.fda.gov/ForIndustry/DataStandards/StructuredProductLabeling/ucm240580.htm
  # http://www.fda.gov/downloads/ForIndustry/DataStandards/StructuredProductLabeling/UCM363569.csv
  def deploy_spl_to_ndc_mapping
    log_header "Deploying SPL to NDC Mappings"

    data_dir = ServerConfig.expand_path("#{@@path}/../data/spl-to-ndc")
    data_file = ServerConfig.expand_path("#{@@path}/../data/spl-to-ndc/UCM363569.csv")
    unless File.exist?(data_file)
      logger.info "Downloading the mappings for your..."
      FileUtils.mkdir_p(data_dir) unless Dir.exists?(data_dir)
      `curl -o #{data_file} http://www.fda.gov/downloads/ForIndustry/DataStandards/StructuredProductLabeling/UCM363569.csv`
    end

    ARGV.push('import')
    ARGV.push('-input_file_path')
    ARGV.push('data/spl-to-ndc')
    ARGV.push('-input_file_type')
    ARGV.push('delimited_text')
    ARGV.push('-delimited_root_name')
    ARGV.push('spl-to-ndc')
    ARGV.push('-output_uri_prefix')
    ARGV.push('/spl-to-ndc/')
    ARGV.push('-output_uri_suffix')
    ARGV.push('.xml')
    ARGV.push('-output_collections')
    ARGV.push('spl-to-ndc')
    ARGV.push('-output_permissions')

    role_name = @properties['ml.app-name'] + "-role"
    ARGV.push("#{role_name},read,#{role_name},update,#{role_name},insert,#{role_name},execute")
    mlcp
  end

  # http://www.nlm.nih.gov/research/umls/mapping_projects/icd9cm_to_snomedct.html
  def deploy_icd9_to_snomed
    log_header "Deploying ICD9 to SNOMED mappings"

    opts = ::Tempfile.new('opts')
    begin
      opts.write(%Q{-input_file_type\ndelimited_text\n-delimiter\n"\t"})
      opts.rewind
      # logger.info opts.path
      ARGV.push('import')
      ARGV.push('-input_file_path')
      ARGV.push('data/icd9-to-snomed')
      ARGV.push('-options_file')
      ARGV.push(%Q{"#{opts.path}"})
      ARGV.push('-input_compressed')
      ARGV.push('-delimited_root_name')
      ARGV.push('icd9-to-snomed')
      ARGV.push('-output_uri_prefix')
      ARGV.push('/icd9-to-snomed/')
      ARGV.push('-output_uri_suffix')
      ARGV.push('.xml')
      ARGV.push('-output_collections')
      ARGV.push('icd9-to-snomed')
      ARGV.push('-transform_module')
      ARGV.push('/transform/icd9-to-snomed-transform.xqy')
      ARGV.push('-transform_namespace')
      ARGV.push('"http://marklogic.com/transform/icd9-to-snomed"')
      ARGV.push('-output_permissions')

      role_name = @properties['ml.app-name'] + "-role"
      ARGV.push("#{role_name},read,#{role_name},update,#{role_name},insert,#{role_name},execute")
      mlcp
    ensure
      opts.close
      opts.unlink
    end
  end

  def deploy_geonames_geo
    log_header "Deploying Zip Code Geo Lookups"

    ARGV.push('import')
    ARGV.push('-input_file_path')
    ARGV.push('data/geonames')
    ARGV.push('-input_compressed')
    ARGV.push('-delimited_root_name')
    ARGV.push('zip_geo')
    ARGV.push('-delimited_uri_id')
    ARGV.push('postal')
    ARGV.push('-output_uri_prefix')
    ARGV.push('/postal/')
    ARGV.push('-output_uri_suffix')
    ARGV.push('.xml')
    ARGV.push('-namespace')
    ARGV.push('geonames.org/zip-geo')
    ARGV.push('-input_file_type')
    ARGV.push('delimited_text')
    ARGV.push('-delimiter')
    ARGV.push('\;')
    ARGV.push('-output_uri_replace')
    ARGV.push(%Q{"#{ServerConfig.expand_path("#{@@path}/../data")},''"})
    ARGV.push('-output_collections')
    ARGV.push('postal')

    ARGV.push('-output_permissions')

    role_name = @properties['ml.app-name'] + "-role"
    ARGV.push("#{role_name},read,#{role_name},update,#{role_name},insert,#{role_name},execute")
    mlcp
  end

  def create_odbc_views
    log_header "Creating ODBC views"
    execute_query(%Q{
      import module namespace co = "http://marklogic.com/conigure-odbc" at "/lib/configure-odbc.xqy";
      co:create-views()
    },
    :app_name => @properties['ml.app-name'])
  end

  def download_faers_data
    log_header "Downloading FAERS data"
    `mkdir -p data/faers`
    filenames = ["UCM429319.zip", "UCM419919.zip", "UCM409968.zip", "UCM399593.zip", "UCM395998.zip", "UCM387234.zip", "UCM364761.zip"]
    filenames.each do |filename|
      unless File.exist?("data/faers/#{filename}")
        `curl -o data/faers/#{filename} http://www.fda.gov/downloads/Drugs/GuidanceComplianceRegulatoryInformation/Surveillance/#{filename}`
        cmd = %Q{unzip -q -o -d data/faers/ data/faers/#{filename}}
        logger.info cmd
        logger.info `#{cmd}`
      end
    end
  end

  def deploy_faers
    log_header "Deploying FAERS   small: #{small}"

    ARGV.push('import')
    ARGV.push('-input_file_path')
    ARGV.push('data/faers')
    ARGV.push('-output_uri_replace')
    ARGV.push(%Q{"#{ServerConfig.expand_path("#{@@path}/../data")},''"})
    ARGV.push('-transform_module')
    ARGV.push('/transform/faers-transform.xqy')
    ARGV.push('-transform_namespace')
    ARGV.push('"http://marklogic.com/transform/faers"')
    ARGV.push('-transform_function')
    ARGV.push('transform')
    ARGV.push('-output_uri_prefix')
    ARGV.push('/faers/')
    ARGV.push('-output_uri_suffix')
    ARGV.push('.xml')
    ARGV.push('-output_collections')
    ARGV.push('faers')
    ARGV.push('-output_permissions')

    role_name = @properties['ml.app-name'] + "-role"
    ARGV.push("#{role_name},read,#{role_name},update,#{role_name},insert,#{role_name},execute")
    mlcp

  end

  def download_diabetes_data
    log_header "Downloading Diabetes data"
    `mkdir -p data/diabetes`
    filename = "dataset_diabetes.zip"
    final_filename = "diabetic_data.csv"
    return if File.exist?("data/diabetes/dataset_diabetes/diabetic_data.csv")

    unless File.exist?("data/diabetes/#{filename}")
      `curl -o data/diabetes/#{filename} https://archive.ics.uci.edu/ml/machine-learning-databases/00296/dataset_diabetes.zip`
    end

    cmd = %Q{unzip -q -o -d data/diabetes/ data/diabetes/#{filename}}
    logger.info cmd
    logger.info `#{cmd}`
  end

  def deploy_diabetes
    download_diabetes_data unless small

    log_header "Deploying Diabetes data   small: #{small}"

    ARGV.push('import')
    ARGV.push('-input_file_path')
    ARGV.push('data/diabetes/dataset_diabetes')
    ARGV.push('-input_file_pattern')
    ARGV.push('diabetic_data\.csv')
    ARGV.push('-input_file_type')
    ARGV.push('delimited_text')
    ARGV.push('-delimited_root_name')
    ARGV.push('diabetes')
    ARGV.push('-transform_module')
    ARGV.push('/transform/diabetes-transform.xqy')
    ARGV.push('-transform_namespace')
    ARGV.push('"http://marklogic.com/transform/diabetes"')
    ARGV.push('-transform_function')
    ARGV.push('transform')
    ARGV.push('-output_uri_prefix')
    ARGV.push('/diabetes/')
    ARGV.push('-output_uri_suffix')
    ARGV.push('.xml')
    ARGV.push('-output_collections')
    ARGV.push('diabetes')
    ARGV.push('-output_permissions')

    role_name = @properties['ml.app-name'] + "-role"
    ARGV.push("#{role_name},read,#{role_name},update,#{role_name},insert,#{role_name},execute")
    mlcp

  end

  def deploy_meddra
    log_header "Deploying MedDRA   small: #{small}"

    ARGV.push('import')
    ARGV.push('-input_file_path')
    unless small
      ARGV.push('data/meddra')
    else
      ARGV.push('data/meddra-small')
    end
    ARGV.push('-input_compressed')
    ARGV.push('true')
    ARGV.push('-input_file_type')
    ARGV.push('RDF')
    ARGV.push('-output_collections')
    ARGV.push('meddra')
    ARGV.push('-output_permissions')

    role_name = @properties['ml.app-name'] + "-role"
    ARGV.push("#{role_name},read,#{role_name},update,#{role_name},insert,#{role_name},execute")
    mlcp

  end

  def deploy_literature
    ARGV.push('import')
    ARGV.push('-input_file_path')
    ARGV.push('data/literature')
    ARGV.push('-output_uri_replace')
    ARGV.push(%Q{"#{ServerConfig.expand_path("#{@@path}/../data")},''"})
    ARGV.push('-output_permissions')

    role_name = @properties['ml.app-name'] + "-role"
    ARGV.push("#{role_name},read,#{role_name},update,#{role_name},insert,#{role_name},execute")
    mlcp

    execute_query(%Q{
      let $perms := (
        xdmp:permission("dmlc-healthcare-role", "read"),
        xdmp:permission("dmlc-healthcare-role", "update"),
        xdmp:permission("dmlc-healthcare-role", "insert"),
        xdmp:permission("dmlc-healthcare-role", "execute")
      )
      for $uri in cts:uri-match('/literature/*.pdf')
      let $file := fn:replace($uri, '.*/([^/]+)$', '$1')
      let $results := xdmp:pdf-convert(fn:doc($uri), $file)
      let $manifest := $results[1]
      for $part at $i in $manifest/*:part
      let $collection :=
        if (fn:ends-with($part, "html")) then "literature"
        else ()
      return
        xdmp:document-insert("/literature/" || $part, $results[$i + 1], $perms, $collection)
    },
    :app_name => @properties['ml.app-name'])
  end

def deploy_news
    ARGV.push('import')
    ARGV.push('-input_file_path')
    ARGV.push('data/news')
    ARGV.push('-output_uri_replace')
    ARGV.push(%Q{"#{ServerConfig.expand_path("#{@@path}/../data")},''"})
    ARGV.push('-output_collections')
    ARGV.push('news')
    ARGV.push('-output_permissions')

    role_name = @properties['ml.app-name'] + "-role"
    ARGV.push("#{role_name},read,#{role_name},update,#{role_name},insert,#{role_name},execute")
    mlcp
  end

  def deploy_content
    # eat the argv to prevent errors
    small

    deploy_users
    deploy_codes
    deploy_spl_to_ndc_mapping unless small
    deploy_rxnorm
    deploy_atc
    deploy_nddf
    deploy_icd9_to_snomed
    deploy_geonames_geo

    deploy_provider_charge_data
    deploy_npi

    deploy_spl
    deploy_claims
    deploy_patient_records

    deploy_meddra
    deploy_literature
    deploy_news
    deploy_faers
    deploy_diabetes
    deploy_prescriber_charge
  end

  def create_scheduled_tweets()
    r = execute_query %Q{
      xquery version "1.0-ml";
      import module namespace admin = "http://marklogic.com/xdmp/admin"
          at "/MarkLogic/admin.xqy";

      let $config := admin:get-configuration()

      let $task := admin:group-minutely-scheduled-task(
        "/lib/ingest-tweets.xqy",
        "#{@properties["ml.modules-root"]}",
        5,
        xdmp:database( "#{@properties["ml.content-db"]}" ),
        xdmp:database( "#{@properties["ml.modules-db"]}" ),
        xdmp:user( "#{@properties["ml.user"]}" ),
        (),
        "normal")

      let $addTask := admin:group-add-scheduled-task($config,
        admin:group-get-id($config, "Default"), $task)

      return
        admin:save-configuration($addTask)
    },
    { :db_name => @properties["ml.content-db"] }
  end

  def delete_scheduled_tweets()
    r = execute_query %Q{
      xquery version "1.0-ml";
      import module namespace admin = "http://marklogic.com/xdmp/admin"
          at "/MarkLogic/admin.xqy";
      declare namespace gr = "http://marklogic.com/xdmp/group";

      let $config := admin:get-configuration()

      let $id :=
        for $task in admin:group-get-scheduled-tasks($config, xdmp:group("Default"))
        where $task/gr:task-path eq "/lib/ingest-tweets.xqy"
        return $task/gr:task-id

      let $deleteTask := admin:group-delete-scheduled-task-by-id($config, xdmp:group("Default"), $id)

      return
        admin:save-configuration($deleteTask)
    },
    { :db_name => @properties["ml.content-db"] }
  end

  def delete_spl_cache()
    r = execute_query %Q{
      xdmp:directory-delete( "/spl-cached-html/" )
    },
    { :db_name => @properties["ml.content-db"] }
  end

  private

  def log_header(txt)
    logger.info(%Q{########################\n# #{txt}\n########################})
  end

  def claims_dir
    @claims_dir ||= small ? "claims-small" : "claims"
  end

  def small
    @small = @small || find_arg(['--small']) != nil
  end
end
