Explicações sobre issues, labels e milestones

# Issues

Crie vários _issues_, um para cada problema.

Eles servem para ajudar na organização do código e no cumprimento dos _milestones_. 

### Lembre-se

todo _issue_ deve ter:

* Título claro
* Boa descrição do problema
* Pelo menos um _label_
* Um nome marcado como responsável (assignee)
* Um _milestone_ associado

### Quando e como fechar

#### Antes de fechar: 

* resolva o problema e avise no _issue_

Não feche simplesmente, à seco, sem dar uma palavra de satisfação! Deixe uma pequena mensagem dizendo que resolveu, e se possível explique como foi solucionado (inclua _commits_ ou números de linhas de código para clareza).

#### Fechando:

* Se você criou um _issue_, feche-o somente após resolver o problema.
* Se foi o professor que o criou, entenda o que está sendo pedido e resolva. Feche-o apenas após resolver o problema.

Os _issues_ são parte importante da organização do código. Eles servem como lembretes do que precisa ser feito. Se fechados antes da solução implementada, você estaria contando com sua memória para lembrar do que precisa ser feito. Isso não é viável quando se tem muitos projetos em andamento. Deixe o _issue_ **aberto** até que realmente tenha solucionado o problema, tenha feito um _commit_ com a solução ou realizado a tarefa indicada.

Para fechar, após 1. resolver o problema, e 2. escrever uma pequena mensagem no _issue_ dizendo que está solucionado (e como), você pode usar um método automático:

No alto da tela, onde está o _issue_, tem o número dele. Ao fazer um _commit_, inclua ao final da mensagem de _commit_ os termos **fix #X**, onde `X` é o número do _issue_. 

Por exemplo, se você quer fechar o _issue_ número `1` que tratava de um erro de sintaxe, diretamente de um _commit_, faça uma mensagem assim:

`git cm "erro de sintaxe: faltou um ; fix #1"`

Isso irá fechar o _commit_ automaticamente após o _push_. Faça isso no `develop`, claro. Sempre trabalhe no `develop`, compile e teste, e só então passe para o `master`.

Se você quiser apenas criar um _link_ para referência, sem fechar o _issue_, basta colocar o número do _issue_ sem a palavra _fix_. Por exemplo:

`git cm "tentando achar o erro de sintaxe ref. fix #1"`

Deste modo sua mensagem de _commit_ fica bem clara e no _issue_ você tem espaço para explicar melhor o que está acontecendo.

# Labels

Criar _labels_, se ainda nao tiver criado:

* _Label_ "task" : amarelo (para uso exclusivo do professor)
* _Label_ "urgent" : vermelho 
* _Label_ "late" : azul
* Crie outros _labels_ que achar necessário se desejar.

Não marque nada como "task". O _label_ "task" será usado pelo professor para indicar tarefas e sub-objetivos durante o projeto. Assim ficará fácil pesquisar os _issues_ que o professor marcou.

# Milestones

Criar _milestones_ se ainda nao tiver criado.

Veja com o professor os títulos, os prazos e a descrição de cada _milestone_.

Como padrão, o **título** do _milestone_ será sempre `vX.Y`, onde:

* `v` significa versão
* `X` é o número "MAJOR", ou seja, o número "maior" da versão
* `Y` é o número "MINOR", ou seja, um número que acompanha pequenos ajustes no código.


Bom trabalho!

@drbeco

---

* Este _issue_ foi criado automaticamente. Após ler e resolver o que está acima detalhado, pode fechar. Se já fez as tarefas aqui descritas, desconsiderei-o e feche-o.

