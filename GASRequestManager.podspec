{\rtf1\ansi\ansicpg1251\cocoartf1344\cocoasubrtf720
{\fonttbl\f0\fmodern\fcharset0 Courier;}
{\colortbl;\red255\green255\blue255;}
\paperw11900\paperh16840\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\deftab720
\pard\pardeftab720\sl320

\f0\fs24 \cf0 \expnd0\expndtw0\kerning0
Pod::Spec.new do |s|\
\
    s.name              = \'91GASRequestManager'\
    s.version           = \'911.0.0'\
    s.summary           = 'Engine for network and requests, based on AFNetworking (for requests) and FastEasyMapping (for mapping).'\
    s.homepage          = 'https://github.com/DarkKor/GASRequestManager'\
    s.license           = \{\
        :type => 'MIT',\
        :file => 'LICENSE'\
    \}\
    s.author            = \{\
        \'91DimaKor' => \'91dimakor3@gmail.com'\
    \}\
    s.source            = \{\
        :git => 'https://github.com/DarkKor/GASRequestManager.git',\
        :tag => s.version.to_s\
    \}\
    s.source_files      = \'92Source/*.\{m,h\}'\
    s.requires_arc      = true\
\
end\
}