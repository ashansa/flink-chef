
master_ip = private_recipe_ip("flink","jobmanager")

group node[:hadoop][:group] do
  action :create
end

user node[:flink][:user] do
  supports :manage_home => true
  action :create
  home "/home/#{node[:flink][:user]}"
  system true
  shell "/bin/bash"
  not_if "getent passwd #{node[:flink]['user']}"
end

group node[:hadoop][:group] do
  action :modify
  members ["#{node[:flink][:user]}"]
  append true
end

ark "flink" do
  if version = "0.10.1"
    url node[:flink][:url]
  else
    url node[:flink][:archiveurl]
  version node[:flink][:version]
  path node[:flink][:home]
  home_dir "#{node[:flink][:dir]}/flink"
  #     checksum  "#{node[:flink][:checksum]}"
  append_env_path true
  owner "#{node[:flink][:user]}"
end

file "#{node[:flink][:home]}/conf/flink-conf.yaml" do 
  owner node[:flink][:user]
  action :delete
end


template "#{node[:flink][:home]}/conf/flink-conf.yaml" do
    source "flink-conf.yaml.erb"
    owner node[:flink][:user]
    group node[:hadoop][:group]
    mode 0775
  variables({
              :jobmanager_ip => master_ip
            })
end
