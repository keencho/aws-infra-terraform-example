import {APP_TYPE} from "@common/env.model.ts";
import {useEffect, useState} from "react";

interface Account {
    loginId: string
    password: string
    name: string
    createdAt?: string
}

export function App() {

    const [list, setList] = useState<Account[]>([])
    const [accountData, setAccountData] = useState<Account>({ loginId: '', password: '', name: '' })

    const handleAccountData = (key: keyof Account, value: string) => {
        setAccountData(pv => ({ ...pv, [key]: value }))
    }

    const listAll = () => {
        fetch('/api/account')
            .then(res => res.json())
            .then(setList)
    }

    useEffect(() => {
        listAll()
    }, []);

    const save = () => {
        if (!accountData.loginId || !accountData.password || !accountData.name) {
            alert('모든 정보를 입력하세요.')
            return
        }

        fetch('/api/account', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(accountData)
        })
            .then((res) => {
                if (!res.ok) {
                    alert('저장 실패')
                    return
                }
                setAccountData({ loginId: '', name: '', password: '' })
                listAll()
            })
    }

    const del = (loginId: string) => {
        fetch('/api/account', {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ loginId: loginId })
        }).then((res) => {
            if (!res.ok) {
                alert('삭제 실패')
                return
            }
            listAll()
        })
    }

    return (
        <div>
            <h1>앱 타입: {APP_TYPE}</h1>
            <div style={{ display: 'flex', flexDirection: 'column' }}>
                <div style={{ display: 'flex', flexDirection: 'column' }}>
                    <h2>계정생성</h2>
                    <div style={{display: 'flex', flexDirection: 'row', gap: '16px'}}>
                        <div>
                            <span>LOGIN ID: </span>
                            <input value={accountData.loginId}
                                   onChange={(e) => handleAccountData('loginId', e.target.value)}/>
                        </div>
                        <div>
                            <span>PASSWORD: </span>
                            <input value={accountData.password}
                                   onChange={(e) => handleAccountData('password', e.target.value)}/>
                        </div>
                        <div>
                            <span>NAME: </span>
                            <input value={accountData.name}
                                   onChange={(e) => handleAccountData('name', e.target.value)}/>
                        </div>

                        <button onClick={save}>추가</button>

                    </div>
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', marginTop: '32px' }}>
                    <h2>계정 리스트 <button onClick={listAll}>다시 불러오기</button> </h2>
                    <div>
                        <table>
                            <tr>
                                <th>LOGIN ID</th>
                                <th>PASSWORD</th>
                                <th>NAME</th>
                                <th>CREATED AT</th>
                                <th></th>
                            </tr>
                            {
                                list.map(item => (
                                    <tr key={item.loginId}>
                                        <td>{item.loginId}</td>
                                        <td>{item.password}</td>
                                        <td>{item.name}</td>
                                        <td>{item.createdAt}</td>
                                        <td>
                                            <button onClick={() => del(item.loginId)}>삭제</button>
                                        </td>
                                    </tr>
                                ))
                            }
                        </table>
                    </div>
                </div>
            </div>
        </div>
    )
}