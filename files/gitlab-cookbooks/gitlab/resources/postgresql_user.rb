resource_name :postgresql_user

property :username, String, name_property: true
property :password, String
property :options, Array, default: []
property :helper, default: PgHelper.new(node)

action :create do
  account_helper = AccountHelper.new(node)

  query = "CREATE USER #{username} #{options.join(' ')}"
  query << " PASSWORD '#{password}'" unless password.nil?

  execute "create #{username} postgresql user" do
    command %(/opt/gitlab/bin/#{helper.service_cmd} -d template1 -c "#{query}")
    user account_helper.postgresql_user
    # Added retries to give the service time to start on slower systems
    retries 20
    not_if { !helper.is_running? || helper.user_exists?(username) }
  end
end
