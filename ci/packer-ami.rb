#!/usr/bin/env ruby
# https://gist.github.com/nabeken/8c26b7335348e8e4c916
require 'open3'
require 'yaml'

ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))

def load_yaml(str)
  YAML.load(str) || {}
end

def update_ami_id(name, ami_id)
  File.open("#{ROOT_DIR}/images.yml", File::RDWR|File::CREAT, 0644) { |f|
    f.flock(File::LOCK_EX)

    images = load_yaml(f.read) || {}
    images[name] = ami_id

    f.rewind
    f.write(images.to_yaml)
    f.truncate(f.pos)
  }
end

def is_ami_up_to_date(name)
  images = load_yaml(open("#{ROOT_DIR}/images.yml").read)
  !images[name].nil?
end

case ARGV[0]
when 'build'
  template_name = ARGV[1]

  if template_name.nil?
    STDERR.puts "must specify a template name"
    exit 1
  end

  if is_ami_up_to_date(template_name)
    puts "#{template_name} is up-to-date."
    exit 0
  end

  Dir.chdir("#{ROOT_DIR}/packer") { |path|
    Open3.popen2e("packer build #{template_name}.json") { |i, oe, t|
      i.close_write
      last_line = ''
      oe.each { |l|
        print l
        last_line = l.strip
      }

      status = t.value
      if status.success?
        ami_id = last_line[/ami-.*/]
        if ami_id.nil? || ami_id.empty?
          puts "ami id is #{ami_id}"
          STDERR.puts "failed to get ami id from the last line. something is wrong."
          #exit 1
        end

        update_ami_id(template_name, ami_id)
      else
        exit 1
      end
    }
  }
end
