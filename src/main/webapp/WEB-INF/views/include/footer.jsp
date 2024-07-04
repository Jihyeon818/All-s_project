<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    response.setHeader("Cache-Control","no-store");
    response.setHeader("Pragma","no-cache");
    response.setDateHeader("Expires",0);
    if (request.getProtocol().equals("HTTP/1.1"))
        response.setHeader("Cache-Control", "no-cache");
%>

<footer>
    <button class="secondary-default top">
        <i class="bi bi-caret-up-fill"></i>
        <span>TOP</span>
    </button>
    <div class="teammember">
        <div class="logo">
            <p>made by</p>
            <img class="footerlogo" src="${root}/resources/images/logo.png" style="width:8em" alt="all's 로고"/>
        </div>
        <div class="madeby">
            <ul>
                <li>전상민</li>
                <li><a href="#"> github</a></li>
                <li><a href="#"> notion</a>
                </li>
            </ul>
        </div>
        <div class="madeby">
            <ul>
                <li>신지현</li>
                <li><a href="#">github</a></li>
                <li><a href="#">notion</a>
                </li>
            </ul>
        </div>
        <div class="madeby">
            <ul>
                <li>송예준</li>
                <li><a href="#">github</a></li>
                <li><a href="#">notion</a>
                </li>
            </ul>
        </div>
        <div class="madeby">
            <ul>
                <li>최재원</li>
                <li><a href="#">github</a></li>
                <li><a href="#">notion</a>
                </li>
            </ul>
        </div>
        <div class="madeby">
            <ul>
                <li>손유정</li>
                <li><a href="#">github</a></li>
                <li><a href="#">tstory</a>
                </li>
            </ul>
        </div>
        <div class="madeby">
            <ul>
                <li>조서영</li>
                <li><a href="#">github</a></li>
                <li><a href="#">notion</a>
                </li>
            </ul>
        </div>
    </div>
    <div>© 2021 All Rights Reserved</div>
</footer>