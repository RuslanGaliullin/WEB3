## Галиуллин Руслан БПИ217

### Изменения

1. transfer. Добавляю к значению каждого трансфера 10
2. approve. Делаю всем approve в размере 0
3. _update. Для четных значений from делаю нулевым адресом

### Команды
Вызов из корня репозитория

internal тестирование

```echidna . --contract CryticERC20InternalHarness --config test/crytic/erc20/echidna-internal.yaml```

external тестирование

```echidna . --contract CryticERC20ExternalHarness --config test/crytic/erc20/echidna-external.yaml```


## Нарушенные свойства

1. transferZeroAmount
    
i. Почему ломается:  
   Тест «передача нуля» (transferZeroAmount) обычно проверяет, что при вызове transfer(msg.sender, 0) не происходит никаких изменений баланса или не выбрасывается ошибка. Но в нашем изменённом контракте, даже если передать value = 0, фактически вызывается _transfer(.., value + 10), то есть 10 токенов всё равно будут списаны у отправителя и зачислены получателю. Это и ломает логику «передачи нуля».  

ii. Какое изменение к этому привело:  
   В функции transfer(address to, uint256 value) добавлена строка value + 10 вместо value.  
   function transfer(...) public virtual override returns (bool) {  
       ...  
       _transfer(owner, to, value + 10);  
       ...  
   }  

2. transfer

i. Почему ломается:  
   Обычно тест на обычную передачу (transfer) ожидает, что при вызове transfer(to, value) ровно value токенов перейдёт из баланса отправителя к получателю. У нас же передаётся value + 10, то есть токенов списывается (и зачисляется) на 10 больше, чем запрашивает пользователь. Тесты, сравнивающие «ожидаемое количество = value» с реальным, проваливаются.  

ii. Какое изменение к этому привело:  
   В функции transfer(address to, uint256 value) добавлена строка value + 10 вместо value.  
   function transfer(...) public virtual override returns (bool) {  
       ...  
       _transfer(owner, to, value + 10);  
       ...  
   }   

3. selfTransfer

i. Почему ломается:  
   Тест selfTransfer (передача самому себе) обычно проверяет, что при transfer(msg.sender, value) баланс не меняется или корректно перераспределяется (списывается и зачисляется обратно). Но раз у нас добавляются лишние 10 токенов, то при передаче самому себе будет происходить списание и зачисление на value + 10.  

ii. Какое изменение к этому привело:  
   В функции transfer(address to, uint256 value) добавлена строка value + 10 вместо value.  
   function transfer(...) public virtual override returns (bool) {  
       ...  
       _transfer(owner, to, value + 10);  
       ...  
   }    

4. setAllowance

i. Почему ломается:  
   Обычный тест setAllowance (approve) проверяет, что владелец может установить конкретное значение allowance для определённого spender. Например, approve(spender, 100) должно привести к allowances[owner][spender] = 100. Однако из-за модифицированного кода approve фактически всегда устанавливает allowance в 0, игнорируя переданный параметр.  

ii. Какое изменение к этому привело:  
   В функции approve(...) прибитое гвоздями значение:  
   function approve(address spender, uint256) public virtual override returns (bool) {  
       _approve(spender, owner, 0);  
       return true;  
   }  
   То есть игнорируется второй аргумент и всегда проставляется 0.  

5. setAllowanceTwice

i. Почему ломается:  
   Тест setAllowanceTwice проверяет ситуацию, когда владелец дважды подряд вызывает approve с разными значениями. Например, сначала approve(spender, 100), потом approve(spender, 50), и ожидается, что итоговый allowance будет 50. Но поскольку код всегда ставит 0, результат теста не совпадает с ожидаемым.  

ii. Какое изменение к этому привело:  
   Аналогично предыдущему пункту: функция approve(…) игнорирует входной параметр и устанавливает allowance в 0 каждый раз.

6. transferMoreThanBalance

i. Почему ломается:  
   Тест transferMoreThanBalance обычно проверяет, что при попытке перевести больше токенов, чем есть на балансе, transfer вернет false, а функция transfer у нас всегда возвращает true.

ii. Какое изменение к этому привело:  
```
   function transfer(
        address to,
        uint256 value
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value + 10);
        return true;
    }
``` 
