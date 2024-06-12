# story_consoleManager
Console Manager for FiveM (vRP)

## 소개
서버 콘솔에서 명령어를 통해 유저를 관리할 수 있는 시스템입니다.<br/>
보다 빠르고 편리한 서버 관리를 가능하게 합니다.<br/><br/>
본 리소스는 일반적으로 `Dunko vRP` 프레임워크와 호환되며, 스토리 서버에 적용된 리소스와 다른 구조임을 알립니다.

## 명령어
아래는 `story_consoleManager`가 지원하는 명령어 목록입니다.

### [+] 추가
> - `prefix add cash *id* *value*` *id*번에게 *value*원을 현금으로 지급합니다.
> - `prefix add bank *id* *value*` *id*번에게 *value*원을 계좌로 지급합니다.
> - `prefix add item *id* *value (아이템 코드)* *amount*` *id*번에게 *value* 아이템을 *amount*개 지급합니다.
> - `prefix add vehicle *id* *value (차량 코드)*` *id*번에게 차량 *value*을(를) 지급합니다.
> - `prefix add group *id* *value (그룹명)*` *id*번에게 직급 *value*을(를) 지급합니다.

### [-] 제거
> - `prefix remove cash *id* *value*` *id*번의 현금 *value*원을 차감합니다.
> - `prefix remove bank *id* *value*` *id*번의 계좌 잔고 *value*원을 차감합니다.
> - `prefix remove item *id* *value (아이템 코드)* *amount*` *id*번의 *value* 아이템을 *amount*개 차감합니다.
> - `prefix remove vehicle *id* *value (차량 코드)*` *id*번의 차량 *value*을(를) 제거합니다.
> - `prefix remove group *id* *value (그룹명)*` *id*번의 직급 *value*을(를) 제거합니다.

### [/] 초기화
> - `prefix reset cash *id*` *id*번의 현금을 0원으로 초기화합니다.
> - `prefix reset bank *id*` *id*번의 계좌 잔고를 0원으로 초기화합니다.
> - `prefix reset item *id*` *id*번의 인벤토리를 초기화합니다.
> - `prefix reset vehicle *id*` *id*번의 차고지를 초기화합니다.

> - `prefix reset newbiecode *id*` *id*번의 뉴비 인증 코드를 제거합니다.
> - `prefix reset newbiecode-discord *id*` *id*번의 뉴비 인증 코드의 상태 (state)를 '1'로 변경합니다. ('1' = 디스코드 인증 완료처리)
> - `prefix reset newbiecode-reward *id*` *id*번의 뉴비 인증 코드의 상태 (state)를 '2'로 변경합니다. ('2' = 보상 수령 완료처리)

### [!] 제재
> - `prefix kick *id* *reason*` *id*번을 *reason*사유로 서버에서 추방합니다.
> - `prefix ban *id* *reason*` *id*번을 *reason*사유로 서버에서 차단합니다.

## 설정 방법
1. `src/server/server.lua`에서 다음 사항을 변경합니다.

```lua
local OverExtended = exports['oxmysql'] -- OxMySQL 리소스명을 입력합니다.

local database = {
    vehicle = 'vrp_user_vehicles', -- 차고지 데이터베이스 테이블명을 입력합니다.
    newbie = 'vrp_newbie_bonus' -- 뉴비 인증 데이터베이스 테이블명을 입력합니다.
}

-- .. code

AddEventHandler('rconCommand', function(commandName, args)
    local prefix = 'story' -- 접두사를 설정합니다. (ex. itsruin add cash 1 10000)

    -- .. code
end)
```