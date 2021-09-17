# Capítulo 4: Primeira aplicação no OCI

## 4.5 - Introdução ao Serviço de Load Balancer

### __Introdução__

_Load Balancer_, _Balanceador de Carga_ ou _LBaaS_ são alguns nomes que identificam o _[Serviço de Load Balancing](https://docs.oracle.com/pt-br/iaas/Content/Balance/Concepts/balanceoverview.htm)_ disponível no _[OCI](https://www.oracle.com/cloud/)_.

Sua principal função é realizar a distribuição do tráfego de um ponto de entrada, para vários servidores existentes em sua _[VCN](https://docs.oracle.com/pt-br/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm)_. Além de distribuir a _"carga de trabalho"_ entre duas ou mais intâncias de computação, temos uma melhor utilização dos recursos, possibilidade de escalonamento e alta disponibilidade.

Abaixo iremos listar algumas propriedades e características do serviço que serão úteis quando formos criar o nosso:

- **Público ou Privado**
    - Um balanceador de carga _**público**_ é criado em uma subrede pública com um endereço IP público e acessível pela internet. Este pode ser criado em uma subrede regional no qual irá consumir dois endereços IPs privados, ou pode ser criado em duas subredes públicas sobre dois _[ADs](https://docs.oracle.com/pt-br/iaas/Content/General/Concepts/regions.htm#About)_ diferentes, consumindo dois endereços IPs privados por _[ADs](https://docs.oracle.com/pt-br/iaas/Content/General/Concepts/regions.htm#About)_.
   - Já um balancedor de carga _**privado**_ é criado em uma subrede privada com o intuito de não receber requisições pela internet e fazer _"frente"_ somente com recursos internos. Neste caso será consumido três endereços IPs privados da subrede.
    - Em ambos, há um endereço IP principal que possui a característica de ser _"flutuante"_. Ou seja, ele se alternará para o balanceador de carga secundário (standby) em caso de falha no principal.

- **Listener**
    - Você configura um _**listener**_ para tratar conexões através dos protocolos de _[Camada 7](https://pt.wikipedia.org/wiki/Camada_de_aplica%C3%A7%C3%A3o)_ (_[HTTP](https://pt.wikipedia.org/wiki/Hypertext_Transfer_Protocol)_, _[HTTPS](https://pt.wikipedia.org/wiki/Hyper_Text_Transfer_Protocol_Secure)_ ou _[HTTP/2](https://pt.wikipedia.org/wiki/HTTP/2)_) ou _[Camada 4](https://pt.wikipedia.org/wiki/Camada_de_transporte)_ (_[TCP](https://pt.wikipedia.org/wiki/Transmission_Control_Protocol)_) em portas específicas.
    - Você pode definir vários _**listener**_ que tratam um determinado protocolo em portas diferentes.

- **Backend**    
    - Um _"conjunto de backend"_ é uma entidade lógica onde é possível agrupar suas instâncias de aplicação que são responsáveis por gerar conteúdo em resposta ao tráfego TCP ou HTTP recebido.        
    - A ideia é sempre ter mais de uma instância (cópia) da sua aplicação dentro de uma configuração de _backend_, empregando assim a _["alta disponibilidade"](https://en.wikipedia.org/wiki/High_availability)_.
    - É possível escolher instâncias de diferentes compartimentos para compor o seu _"conjunto de backend"_.
    - Configurar a comunicação através do protocolo _[SSL](https://pt.wikipedia.org/wiki/Transport_Layer_Security)_, a partir do _[Load Balancer](https://docs.oracle.com/pt-br/iaas/Content/Balance/Concepts/balanceoverview.htm)_ até o _"conjunto de backend"_, é possível porém opcional. Vai da sua necessidade.

- **Health Check**
    - _"Health Check"_ ou verificação de integridade, é um teste realizado pelo _[Load Balancer](https://docs.oracle.com/pt-br/iaas/Content/Balance/Concepts/balanceoverview.htm)_ para confirmar a disponibilidade das suas instâncias contidas no _"conjunto de backend"_ (monitorar). Caso uma instância não responda com sucesso ao teste, o _[Load Balancer](https://docs.oracle.com/pt-br/iaas/Content/Balance/Concepts/balanceoverview.htm)_ retira temporariamente esta instância do _"conjunto de backend"_. O teste continua e caso futuramente a instância volte a operar, ela é colocada novamente ao _"conjunto de backend"_.
    - Os testes podem ser feitos em nível _[TCP](https://pt.wikipedia.org/wiki/Transmission_Control_Protocol)_ (abertura de _[socket](https://pt.wikipedia.org/wiki/Soquete_de_rede)_) ou consultando diretamente a aplicação, por uma _[URI](https://pt.wikipedia.org/wiki/URI)_ que você especifica.
    - Não há comunicação com a instância, caso o _"Health Check"_ falhe.

- **Política de Balanceamento**
    - A política de balanceamento informa como distribuir o tráfego de entrada para o _"conjunto de backend"_.
    - Atualmente temos três diferentes políticas. São elas:
        1. **Weighted Round Robin (Revezamento)**
            - É um algoritmo de balanceamento simples que distribui o tráfego de forma sequencial para cada instância contida no _"conjunto de backend"_.
            - Esta é uma política que funciona melhor quando todas as instâncias do _backend_  possuem capacidade computacional semelhante.

        2. **IP hash**
            - Esta política calcula um _[Hash](https://pt.wikipedia.org/wiki/Fun%C3%A7%C3%A3o_hash)_ sobre o IP de origem de uma solicitação recebida, com a finalidade de enviar o tráfego para a mesma instância do _backend_.
            - Garante que as solicitações de um cliente específico sejam sempre direcionadas para o mesmo servidor no _backend_.
        
        3. **Least connections (Menos conexões)**
            - Esta política irá encaminhar tráfego para a instância de  _backend_ com menos conexões ativas.

- **Gerenciamento de Certificados SSL**
    - O _[Serviço de Load Balancing](https://docs.oracle.com/pt-br/iaas/Content/Balance/Concepts/balanceoverview.htm)_ permite tratar conexões seguras _[HTTPS](https://pt.wikipedia.org/wiki/Hyper_Text_Transfer_Protocol_Secure)_. Para isto, você deve fazer upload do seu certificado público, chave privada correspondente e quaisquer outros certificados da cadeia de validação. 
    - Tratar conexões _[HTTPS](https://pt.wikipedia.org/wiki/Hyper_Text_Transfer_Protocol_Secure)_ diretamente no _[Load Balancer](https://docs.oracle.com/pt-br/iaas/Content/Balance/Concepts/balanceoverview.htm)_, elimina sobrecarga e qualquer outra configuração nos servidores de aplicação.