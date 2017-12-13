# Caronaê - iOS

Aplicativo para iPhone do Caronaê.

**Requisitos:**

* Xcode 9+
* iOS 8.2+
* [CocoaPods](https://cocoapods.org) 1.3.1


## Instalação

Caso não tenha o CocoaPods instalado, instale-o pelo Terminal:

```bash
sudo gem install cocoapods
```

Para rodar o projeto, clone este repositório e, pelo Terminal, navegue até o diretório dele. 
Uma vez no diretório, instale as dependências necessárias usando o CocoaPods:

```bash
pod install
```

Ao concluir, abra o projeto pelo arquivo **Caronae.xcworkspace**.


## Fastlane

Este projeto está configurado com o [fastlane](http://fastlane.tools). Consulte a [documentação](https://github.com/caronae/caronae-ios/tree/develop/fastlane) da pasta fastlane para ver as ações disponíveis.

Para instalar o fastlane, execute:

```bash
bundle install
```


## Firebase Cloud Messaging

Este projeto faz uso da plataforma [Firebase](https://firebase.google.com/) para receber notificações push. Para fazer uso desse recurso é necessário gerar e adicionar o arquivo `GoogleService-Info.plist` dentro do diretório deste projeto.

Consulte a [documentação](https://firebase.google.com/docs/ios/setup) para saber mais informações. Um exemplo do arquivo pode ser encontrado em: `Caronae/Supporting Files/GoogleService-Info.plist.example`.
