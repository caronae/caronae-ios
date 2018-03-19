# Caronaê - iOS

[![CircleCI](https://circleci.com/gh/caronae/caronae-ios.svg?style=svg)](https://circleci.com/gh/caronae/caronae-ios)

Aplicativo para iPhone do Caronaê.

**Requisitos:**

* Xcode 9+
* iOS 9.0+


## Instalação

Instale as ferramentas do projeto através do Terminal:

```bash
bundle install
```

Em seguida, instale as dependências necessárias usando o CocoaPods:

```bash
bundle exec pod install
```

Ao concluir, abra o projeto pelo arquivo **Caronae.xcworkspace**.


## Fastlane

Este projeto está configurado com o [fastlane](http://fastlane.tools). Consulte a [documentação](/fastlane) da pasta fastlane para ver as ações disponíveis.

O Fastlane é instalado através do comando `bundle install`.


## Firebase Cloud Messaging

Este projeto faz uso da plataforma [Firebase](https://firebase.google.com/) para receber notificações push. Para fazer uso desse recurso é necessário gerar e adicionar o arquivo `GoogleService-Info.plist` dentro do diretório deste projeto.

Consulte a [documentação](https://firebase.google.com/docs/ios/setup) para saber mais informações. Um exemplo do arquivo pode ser encontrado em: `Caronae/Supporting Files/GoogleService-Info.plist.example`.
