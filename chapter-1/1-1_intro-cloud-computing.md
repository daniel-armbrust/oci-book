# Capítulo 1: Conceitos e introdução a Computação em Nuvem no OCI

## 1.1 - Introdução a Computação em Nuvem

### __Introdução__

Antigamente, implantávamos sistemas (deploy) ou em máquinas pequenas, ou em máquinas onde abrigavam vários diferentes sites. Esta única máquina é o gargalo (problema). Você nunca sabe se esta máquina aguenta uma carga maior de acessos. E caso ela de fato não aguente, você não tem para onde ir.

A partir deste tipo de problema, surgiram algumas soluções dentro de um mundo que conhecemos hoje como **"Cloud Computing" (Computação em Nuvem ou computação nas nuvens)**. Neste mundo, eu não estou restrito a uma única máquina. Minha aplicação está dentro de uma "máquina virtual", que está dentro de uma infraestrutura virtual, na qual eu consigo replicar (clones) quantas máquinas eu quiser, na demanda que eu necessitar (em tempo real pelo acesso crescente). Neste modelo, eu não preciso ligar para um time de suporte, para solicitar uma nova máquina e esta estar disponível somente 48 horas depois.

No mundo cloud, há flexibilidade. Basicamente, eu posso desenvolver o meu software, esperando ou não, uma demanda crescente de acesso a ele. Eu tenho a minha disposição, uma infraestrutura elástica. Com isto, eu posso evoluir e não ficar "preso" em uma única máquina. Quando você tem um produto web, no qual você espera um volume de acessos incertos (no mundo Internet isto é incontrolável), o mundo cloud surge como solução.

- Concluíndo: _"O mundo cloud foi feito para um momento de demanda imprevísivel."_

Algumas novas linguagens de programação, como o ruby on rails, foi criado em um mundo de startups que é diferente do mundo coorporativo, onde há o desenvolvimento de sistemas internos ou aqueles que ninguém vê. A comunidade de startups tem exigências para a web que incluem escalabilidade, usabilidade, desempenho para criar bons produtos e atrair mais pessoas. Foi criado todo um ferramental, um conjunto de boas práticas, um ciclo de vida de desenvolvimento completamente inspirado no mundo ágil que garante um tipo de software no qual possui "código evolutivo".