FROM node

# 앱 디렉터리 생성
WORKDIR /usr/src/app

# 앱 의존성 복사
COPY package.json ./

# 코드 빌드
RUN npm install

# 앱 소스 추가
COPY . .

EXPOSE 8080
CMD [ "node", "server.js" ]