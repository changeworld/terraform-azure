task :environment do
  errors = []
  %w(
    TF_VAR_subscription_id
    TF_VAR_client_id
    TF_VAR_client_secret
    TF_VAR_tenant_id
    ARM_SUBSCRIPTION_ID
    ARM_CLIENT_ID
    ARM_CLIENT_SECRET
    ARM_TENANT_ID
    ARM_ACCESS_KEY
  ).each do |name|
    errors << name if ENV[name].nil?
  end

  if errors.any?
    abort "One or more environment variables are empty: #{errors.join(", ")}"
  end
end

task :configure => :environment do
  storage_account_name = "changeworld4terraform"
  container_name = "terraform-state"
  key = "terraform-azure.terraform.tfstate"
  resource_group_name = "Terraform-WestUS"
  sh %Q!terraform remote config -backend=azure -backend-config="storage_account_name=#{storage_account_name}" -backend-config="container_name=#{container_name}" -backend-config="key=#{key}" -backend-config="resource_group_name=#{resource_group_name}"!
end

task :pull => :configure do
  sh "terraform remote pull"
end

task :push => :configure do
  sh "terraform remote push"
end

task :plan do
  sh "terraform plan"
end

task :apply do
  sh "terraform apply"
end

Rake::Task[:plan].enhance([:pull])

Rake::Task[:apply].enhance([:pull]) do
  Rake::Task[:push].invoke
end

task :default => :plan
