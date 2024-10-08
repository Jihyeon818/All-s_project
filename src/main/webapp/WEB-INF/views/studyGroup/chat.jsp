<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%
    response.setHeader("Cache-Control","no-store");
    response.setHeader("Pragma","no-cache");
    response.setDateHeader("Expires",0);
    if (request.getProtocol().equals("HTTP/1.1"))
        response.setHeader("Cache-Control", "no-cache");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>스터디그룹 채팅</title>
    <!-- CSRF 메타 태그 -->
    <meta name="_csrf" content="${_csrf.token}"/>
    <meta name="_csrf_header" content="${_csrf.headerName}"/>
    <!-- CSS 링크 -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${root}/resources/css/chat.css">
    <link rel="stylesheet" href="${root}/resources/css/common.css">
    <!-- jQuery 및 Socket.io -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="http://localhost:82/socket.io/socket.io.js"></script>
</head>
<body>
<!-- 중앙 컨테이너 -->
<div id="container">
    <section class="chatSection">
        <!-- 메뉴 영역 -->
        <!-- 본문 영역 -->
        <main>
            <!-- 채팅 컨테이너 -->
            <div class="chat-container">
                <!-- 채팅 헤더 - 스터디 그룹 제목 -->
                <div class="chat-header">
                    <h1>${study.descriptionTitle}</h1>
                </div>
                <!-- 채팅 메시지 영역 -->
                <div id="chatMessages" class="chat-messages">
                    <c:forEach var="message" items="${messages}">
                        <div class="message ${message.userName == userVo.name ? 'right' : 'left'}">
                            <span class="name">${message.userName}</span>
                            <div class="messageBox">
                                <div class="bubble">
                                    <p>${message.messageContent}</p>
                                </div>
                                <span class="regDate">${message.messageRegdate}</span>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
            <!-- 채팅 입력창 -->
            <div class="input-container">
                <textarea id="messageInput" placeholder="메시지를 입력하세요." cols="75" rows="1"></textarea>
                <button id="sendButton" class="send-button">전송</button>
            </div>
            <!-- JavaScript -->
            <script>
                $(document).ready(function () {
                    var socket = io("http://localhost:82");
                    var messageContainer = document.getElementById('chatMessages');
                    var enterPressed = false; // 플래그 추가

                    function formatDate(dateString) {
                        var date = new Date(dateString);
                        var year = date.getFullYear();
                        var month = ('0' + (date.getMonth() + 1)).slice(-2); // 월은 0부터 시작하므로 +1
                        var day = ('0' + date.getDate()).slice(-2);
                        var hours = ('0' + date.getHours()).slice(-2);
                        var minutes = ('0' + date.getMinutes()).slice(-2);
                        return year + '-' + month + '-' + day + ' ' + hours + ':' + minutes;
                    }

                    function addMessageToChat(message) {
                        var formattedDateTime = formatDate(message.messageRegdate);
                        var newMessageHTML = '<div class="message ' + (message.userName === '${userVo.name}' ? 'right' : 'left')
                            + '"><span class="name">' + message.userName + '</span><div class="messageBox"><div class="bubble"><p>'
                            + message.messageContent + '</p></div><span class="regDateTime">' + formattedDateTime + '</span></div></div>';
                        messageContainer.insertAdjacentHTML('afterbegin', newMessageHTML);  // 메시지를 맨 위에 추가
                        messageContainer.scrollTop = messageContainer.scrollHeight;  // 스크롤을 맨 아래로 이동
                    }

                    // 기존 메시지 날짜 포맷팅
                    $("#chatMessages .message .regDate").each(function () {
                        var originalDate = $(this).text();
                        var formattedDate = formatDate(originalDate);
                        $(this).text(formattedDate);
                    });

                    function getQueryParam(param) {
                        var urlParams = new URLSearchParams(window.location.search);
                        return urlParams.get(param);
                    }

                    function sendMessage() {
                        var messageInput = $("#messageInput");
                        var message = messageInput.val().trim();
                        if (message === "") return;

                        var studyIdx = getQueryParam('studyIdx');

                        var csrfToken = $("meta[name='_csrf']").attr("content");
                        var csrfHeader = $("meta[name='_csrf_header']").attr("content");

                        $.ajax({
                            type: 'POST',
                            url: '${root}/studyGroup/sendMessage',
                            data: {
                                message: message,
                                userName: '${userVo.name}',
                                studyIdx: studyIdx
                            },
                            beforeSend: function (xhr) {
                                if (csrfToken && csrfHeader) {
                                    xhr.setRequestHeader(csrfHeader, csrfToken);
                                }
                            },
                            success: function (response) {
                                console.log('Message sent successfully');
                                messageInput.val('');
                                // 메시지를 서버에 보내기
                                socket.emit('send_msg', {
                                    messageContent: message,
                                    userName: '${userVo.name}',
                                    messageRegdate: new Date().toISOString()
                                });
                            },
                            error: function (xhr, status, error) {
                                console.error('Failed to send message: ' + xhr.responseText);
                            }
                        });
                    }

                    $("#messageInput").off('keydown').on('keydown', function (event) {
                        if (event.key === 'Enter' && !event.shiftKey) {
                            event.preventDefault();
                            if (!enterPressed) { // Enter 키가 여러 번 눌리지 않도록
                                enterPressed = true;
                                sendMessage();
                            }
                        }
                    }).on('keyup', function (event) {
                        if (event.key === 'Enter' && !event.shiftKey) {
                            enterPressed = false; // Enter 키가 떼어졌을 때 플래그 초기화
                        }
                    });

                    $("#sendButton").off('click').on('click', function () {
                        sendMessage();
                    });

                    // 이벤트 리스너 등록
                    socket.on("send_msg", function (data) {
                        console.log(data); // 메시지를 로그로 출력하여 확인
                        addMessageToChat(data);
                    });
                });
            </script>
        </main>
    </section>
</div>
</body>
</html>