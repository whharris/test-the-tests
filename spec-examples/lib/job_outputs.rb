module JobOutputs

  class JobOutput

    attr_reader :output_url

    def initialize(aws, output_url)
      @aws, @output_url = aws, output_url
      @output_uri = URI.parse(@output_url)
    end

    def correct?
      @validation_functions.all? { |m| m.call }
    end

    private

    def output_bucket
      @output_bucket ||= @aws.s3.buckets[@output_uri.host]
    end

    def output_prefix
      # No trailing slash
      @output_uri.path[1..-1].sub(/\/+$/,'')
    end

    def part_file
      output_bucket.objects[part_file_path]
    end

    def output_path
      nil
    end

    def size
      part_file.content_length
    end

    def part_file_path
      "#{output_prefix}/#{output_path}/part-00000"
    end

    def nonzero_size_function
      lambda { size > 0 }
    end

  end

end
