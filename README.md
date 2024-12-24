## Галиуллин Руслан БПИ217

### Изменения

1. approve. Делаю всем approve в размере 0
2. _update. Для четных значений from делаю нулевым адресом и подменяю значение update'а с value на value + 1

### Команды
Вызов из корня репозитория

internal тестирование

```echidna . --contract CryticERC20InternalHarness --config test/crytic/erc20/echidna-internal.yaml```

external тестирование

```echidna . --contract CryticERC20ExternalHarness --config test/crytic/erc20/echidna-external.yaml```


## Нарушенные свойства

1. transferZeroAmount
    
i. Почему ломается:  
   update делается не с value, а value + 1. В итоге target баланс = 1, а не 0

ii. Какое изменение к этому привело:  
   ```
      function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override(ERC20, ERC20Pausable) {
        if (value % 2 == 0) {
            from = address(0);
        }

        super._update(from, to, value + 1);
    } 
   ```

2. transfer

i. Почему ломается:  
   update делается не с value, а value + 1. В итоге делается перевод большего значение

ii. Какое изменение к этому привело:  
   ```
      function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override(ERC20, ERC20Pausable) {
        if (value % 2 == 0) {
            from = address(0);
        }

        super._update(from, to, value + 1);
    } 
   ```

3. selfTransfer

i. Почему ломается:  
   Появляется дополнительный +1 к значению перевода  

ii. Какое изменение к этому привело:  
   ```
      function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override(ERC20, ERC20Pausable) {
        if (value % 2 == 0) {
            from = address(0);
        }

        super._update(from, to, value + 1);
    } 
   ```

4. setAllowance

i. Почему ломается:  
   Обычный тест setAllowance (approve) проверяет, что владелец может установить конкретное значение allowance для определённого spender. Например, approve(spender, 100) должно привести к allowances[owner][spender] = 100. Однако из-за модифицированного кода approve фактически всегда устанавливает allowance в 0, игнорируя переданный параметр.  

ii. Какое изменение к этому привело:  
   В функции approve(...) прибитое гвоздями значение:  
   ```
   function approve(address spender, uint256) public virtual override returns (bool) {  
       _approve(spender, owner, 0);  
       return true;  
   }  
   ```
   То есть игнорируется второй аргумент и всегда проставляется 0.  

5. setAllowanceTwice

i. Почему ломается:  
   Тест setAllowanceTwice проверяет ситуацию, когда владелец дважды подряд вызывает approve с разными значениями. Например, сначала approve(spender, 100), потом approve(spender, 50), и ожидается, что итоговый allowance будет 50. Но поскольку код всегда ставит 0, результат теста не совпадает с ожидаемым.  

ii. Какое изменение к этому привело:  
   Аналогично предыдущему пункту: функция approve(…) игнорирует входной параметр и устанавливает allowance в 0 каждый раз.

6. transferMoreThanBalance

i. Почему ломается:  
   Из-за того, что адрес from делается 0 в настоящем _update добавляется новый токен, а не переводится, поэтому не происходи ожидаемого revert с ERC20InsufficientBalance.

ii. Какое изменение к этому привело:  
```
   function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override(ERC20, ERC20Pausable) {
        if (value % 2 == 0) {
            from = address(0);
        }

        super._update(from, to, value + 1);
    }
``` 
