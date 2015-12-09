# Caronaê - iOS

Requisitos:
* Xcode >= 7
* [CocoaPods](https://cocoapods.org) 0.39

Caso não tenha o CocoaPods instalado, execute no Terminal:

```bash
sudo gem install cocoapods
```

Para rodar o projeto, clone este repositório e, pelo terminal, navegue até o diretório dele. 
Uma vez no diretório, instale as dependências necessárias usando o CocoaPods:

```bash
pod install
```

Ao concluir, abra o projeto pelo aquivo **Caronae.xcworkspace**, que irá abrir o Xcode.

Tente executar o projeto num simulador para ter certeza que as dependências estão funcionando.

Para instalar o app num iPhone, é necessário conectá-lo com um cabo usb e selecioná-lo no canto superior esquerdo do Xcode.
Verifique se você selecionou sua conta da Apple no campo de 'Team', nas opções do projeto. 

Talvez haja algum erro dizendo que você não tem algum certificado ou o dispositivo cadastrado. 
Nesse caso, vai aparecer um botão 'Fix issue' abaixo do campo de escolha do time que irá obter as coisas necessárias. Espere sumir o aviso e tente de novo.

Se na hora de executar aparecer um erro de segurança no Xcode (algo como *"process launch failed: security"*) tente isso:

    Open the Settings app, go to General / Profiles, and you'll see your profile. Mark it trusted and things should start working normally again.
    (http://stackoverflow.com/a/30888983/2752598)
    
Caso continue com erros, o Google é seu melhor amigo :)
