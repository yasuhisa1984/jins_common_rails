require 'happymapper'
require 'base64'
# require 'zip/zip'

module Amazon
  module MWS
    class TransportDocument
      include HappyMapper

      tag 'TransportDocument'
      element :base_64_pdf, String, :tag => 'PdfDocument'
      element :chack_sum, String, :tag => 'Checksum'
      
      def decode_pdf
        puts self.base_64_pdf 
        # data = Base64.decode64(self.base_64_pdf)
        data = self.base_64_pdf.unpack('m')[0]
        puts data
        data
      end
      
      def output_as_zip(file_path)
        dir = File.dirname(file_path)
        FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)
        File.open(file_path, 'wb') do|f|
          f.write(self.decode_pdf)
        end
      end
      
      def output_as_pdf(file_path)
        output_as_zip(file_path)
        Zip::File.open(file_path) do |zip|
          zip.each do |entry|
            Rails.logger.debug "entry #{entry.to_s}"
            # { true } は展開先に同名ファイルが存在する場合に上書きする指定
            zip.extract(entry, change_ext(file_path, ".pdf")) { true }
          end
        end
        File.delete(file_path)
      end
      
      def change_ext(filepath, ext)
        filepath.gsub(/\.[^.]+$/, ext)
      end
    end
  end
end