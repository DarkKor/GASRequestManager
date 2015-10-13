Pod::Spec.new do |s|
    s.name              = 'GASRequestManager'
    s.version           = '1.0.0'
    s.summary           = 'Engine for network and requests, based on AFNetworking (for requests) and FastEasyMapping (for mapping).'
    s.homepage          = 'https://github.com/DarkKor/GASRequestManager'
    s.license           = {
        :type => 'MIT',
        :file => 'LICENSE'
    }
    s.author            = {
        'DimaKor' => 'dimakor3@gmail.com'
    }
    s.source            = {
        :git => 'https://github.com/DarkKor/GASRequestManager.git',
        :tag => 'master'
    }
    s.platform = :ios
    s.ios.deployment_target = "8.0"

    s.source_files      = 'Source/*.{m,h}', 'Source/FEMMappingHelpers/*.{h,m}'
    s.requires_arc      = true

    s.subspec 'Core' do |cs|
        cs.dependency 'AFNetworking'
        cs.dependency 'FastEasyMapping'
        cs.dependency 'MagicalRecord'
    end

end