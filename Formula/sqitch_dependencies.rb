require 'formula'

class SqitchDependencies < Formula
  version    '0.9996'
  url        "https://fastapi.metacpan.org/v1/source/DWHEELER/App-Sqitch-#{stable.version}/META.json", :using => :nounzip
  sha256     'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
  homepage   'http://sqitch.org/'
  depends_on 'cpanminus'
  conflicts_with 'sqitch_maint_depends',
    :because => "sqitch_dependencies and sqitch_maint_depends install the same plugins."

  def install
    arch  = %x(perl -MConfig -E 'print $Config{archname}')
    plib  = "#{HOMEBREW_PREFIX}/lib/perl5"
    ENV['PERL5LIB'] = "#{plib}:#{plib}/#{arch}:#{lib}:#{lib}/#{arch}"
    ENV.remove_from_cflags(/-march=\w+/)
    ENV.remove_from_cflags(/-msse\d?/)

    open 'META.json' do |f|
      JSON.parse(f.read)['prereqs'].each do |mode, prereqs|
        next if ['develop', 'test'].include? mode
        prereqs.each do |time, list|
          list.each do |pkg, version|
            next if pkg == 'perl'
            system "cpanm --local-lib '#{prefix}' --notest #{pkg}"
          end
        end
      end
    end

    # Remove perllocal.pod, since it just gets in the way of other modules.
    rm "#{prefix}/lib/perl5/#{arch}/perllocal.pod", :force => true
  end
end
