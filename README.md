# Caronaê - iOS

Aplicativo para iPhone do Caronaê.

**Requisitos:**

* Xcode 8+
* iOS 8.2+
* [CocoaPods](https://cocoapods.org) 1.1.1


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

Este projeto está configurado com o [fastlane](http://fastlane.tools). Consulte a [documentação](https://github.com/lucaslrolim/caronae-ios/tree/develop/fastlane) da pasta fastlane para ver as ações disponíveis.

Para instalar o fastlane, execute:

```bash
sudo gem install fastlane
```


## Certificados / Provisioning Profiles / App Store

Graças ao fastlane, há ações pré-configuradas para a configuração dos certificados e provisioning profiles necessários. Uma vez que tiver o fastlane instalado, basta executar a lane `match_everything`, que irá fazer o download do que for necessário e garantir que todos os arquivos ainda são válidos no Developer Portal.

```bash
fastlane match_everything
```

Os arquivos são sincronizados através de um repositório privado no GitHub e criptografados com uma senha.

O comando acima só precisa ser executado uma vez no Mac de desenvolvimento. Como o projeto do Xcode já está configurado para utilizar os arquivos gerados por ele, as configurações de Code Signing do projeto **não** devem ser alteradas.
