# Testes do case

Os testes Python verificam o contrato estático do Terraform e não executam `plan`, `apply`, chamadas à API do GCP ou tráfego nas VMs.

Execute na raiz do repositório:

```bash
python3 -m unittest discover -s gcp-secure-network-architecture/tests -v
```

| Categoria | O que verifica | Resultado esperado |
| --- | --- | --- |
| Estrutura | Arquivos separados por responsabilidade e nomes `snake_case` | Todos os arquivos obrigatórios existem e seguem o padrão |
| Entradas | Objetos de variáveis para plataforma, organização, projetos, rede, computação, NGFW e testes | Nenhuma variável monolítica ou grupo ausente |
| Organização | Pasta opcional, dois projetos, billing e política de exclusão | Responsabilidades de aplicações e serviços são parametrizadas |
| Topologia | Duas VPCs, três sub-redes e peering bidirecional | Redes sem dependência de valores fixos do case |
| DNS e saída | Zona privada, Cloud NAT e Flow Logs | Resolução interna e saída controlada estão declaradas |
| Firewall | Políticas associadas, regras de permissão, bloqueio de ingress/egress e logging | Fluxo da aplicação permitido, fluxo de teste bloqueado e protocolos de saída não autorizados negados |
| NGFW | Perfil `THREAT_PREVENTION`, endpoint, associação e ação de inspeção | IDS/IPS é obrigatório no contrato do case |
| Computação | Três VMs sem `access_config`, com papéis distintos e OS Login habilitado | Nenhuma VM possui IP público e a autenticação SSH não depende de chaves em metadata |
| Diagnóstico | Connectivity Tests para caminho permitido e bloqueado | Os dois fluxos possuem teste declarativo |
| Segurança do exemplo | Variáveis fictícias e ausência de chaves ou IDs privados conhecidos | Arquivo de exemplo seguro para publicação |

Esses testes não comprovam que os recursos foram aceitos pelo GCP nem que o IDS/IPS detectou uma ameaça. Essa comprovação exige uma sessão controlada, testes reais e evidências sanitizadas, executados pelo operador.
